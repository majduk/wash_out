xml.instruct!
xml.definitions 'xmlns' => 'http://schemas.xmlsoap.org/wsdl/',
                'xmlns:tns' => @namespace,
                'xmlns:soap' => 'http://schemas.xmlsoap.org/wsdl/soap/',
                'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
                'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                'xmlns:soap-enc' => 'http://schemas.xmlsoap.org/soap/encoding/',
                'xmlns:wsdl' => 'http://schemas.xmlsoap.org/wsdl/',
                'name' => @name,
                'targetNamespace' => @namespace do
  xml.types do
    xml.tag! "schema", :targetNamespace => @namespace, :xmlns => 'http://www.w3.org/2001/XMLSchema' do
      defined = []     
      @map.keys.each do |operation|     
        xml.tag! "xsd:element",  :name => "#{operation}Request", :type => "tns:#{operation}"
        xml.tag! "xsd:element",  :name => "#{operation}Response", :type => "tns:#{operation}Response"
      end
      
      @map.keys.each do |operation|
          xml.tag! "xsd:complexType", :name => operation do
            xml.tag! "xsd:sequence"  do
              @map[operation][:in].each do |value|
                xml.tag! "xsd:element", wsdl_occurence(value, false, :name => value.name, :type => value.namespaced_type)
              end
            end 
          end
          xml.tag! "xsd:complexType", :name => "#{operation}Response" do
            xml.tag! "xsd:sequence"  do
              @map[operation][:out].each do |value|
                xml.tag! "xsd:element", wsdl_occurence(value, false, :name => value.name, :type => value.namespaced_type)
              end
            end 
          end
      end
      
      @map.each do |operation, formats|
        formats[:in].each do |p|
          wsdl_type xml, p, defined
        end
        formats[:out].each do |p|
          wsdl_type xml, p, defined
        end
      end
    end
  end

#  @map.each do |operation, formats|
#    xml.message :name => "#{operation}Request" do #zmaina 2
#      formats[:in].each do |p|
#        xml.part wsdl_occurence(p, true, :name => p.name, :type => p.namespaced_type)
#      end
#    end
#    xml.message :name => "#{operation}Response" do  #zmiana 3
#      formats[:out].each do |p|
#        xml.part wsdl_occurence(p, true, :name => p.name, :type => p.namespaced_type)
#      end
#    end
#  end
   
  @map.keys.each do |operation|
    xml.message :name => "#{@name}_#{operation}" do 
        xml.part :element => "tns:#{operation}Request", :name => "#{operation}Request"
    end
     xml.message :name => "#{@name}_#{operation}Response" do 
        xml.part :element => "tns:#{operation}Response", :name => "#{operation}Response"
    end
  end

  xml.portType :name => "#{@name}_port" do
    @map.keys.each do |operation|
      xml.operation :name => operation, :parameterOrder => "#{operation}Request" do                        #zmiana 6
        xml.input :message => "tns:#{@name}_#{operation}"          #zmiana 5
        xml.output :message => "tns:#{@name}_#{operation}Response" #zmiana 4
      end
    end
  end

  xml.binding :name => "#{@name}_binding", :type => "tns:#{@name}_port" do
    xml.tag! "soap:binding", :style => 'document', :transport => 'http://schemas.xmlsoap.org/soap/http'
    @map.keys.each do |operation|
      xml.operation :name => operation do
        xml.tag! "soap:operation", :soapAction => "#{@namespace}/#{operation}" #zmiana 1
        xml.input do
          xml.tag! "soap:body",
            :use => "literal"            
        end
        xml.output do
          xml.tag! "soap:body",
            :use => "literal"            
        end
      end
    end
  end

  xml.service :name => "service" do
    xml.port :name => "#{@name}_port", :binding => "tns:#{@name}_binding" do
      xml.tag! "soap:address", :location => url_for(:action => '_action', :only_path => false)
    end
  end
  
end