module DOWL

  class Generator
    
    def initialize(schema, template_file, dir)
      @schema = schema
      @template = ERB.new(template_file.read)
      template_file.close() # Do this more safely. We might need to keep it open to read other info from it.
      @dir = dir
      if schema.introduction
        @introduction = File.read(schema.introduction)
      end      
    end
    
    def run()      
      b = binding
      schema = @schema
      introduction = @introduction
      #
      # TODO: Write the output in a file in the target directory
      #
      file = @template.result(b)
      puts file
    end
    
  end  
  
end
