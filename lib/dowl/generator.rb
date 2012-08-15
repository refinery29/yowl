module DOWL

  class Generator
    
    def initialize(schema, template=Generator.default_template())
      @template = ERB.new(File.read(template))
      @schema = schema
      if schema.introduction
        @introduction = File.read(schema.introduction)
      end      
    end
    
    def Generator.default_template()
      template = default_template_file = File.join(schema.dir(), "dowl/default.erb")
      if File.exists?(template)
        return template
      end
      template = default_template_file = File.join(File.dirname(__FILE__), "default.erb")
      if File.exists?(template)
        return template
      end
      raise "Could not find template: default.erb"
    end
    
    def run()      
      b = binding
      schema = @schema
      introduction = @introduction
      return @template.result(b)               
    end
    
  end  
  
end
