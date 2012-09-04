require 'dowl'

module DOWL

  class Import < DOWL::LabelledDocObject
    
    attr_reader :importedOntology
 
    def initialize(resource, schema)
      super(resource, schema)
      
      importedSchema = @schema.repository.getSchemaForImport(self)
      @importedOntology = importedSchema ? importedSchema.ontology : nil
    end
    
    def name
      if @importedOntology
        return @schema.name
      end
      prefix = @schema.prefixForNamespace(uri)
      if prefix
        return prefix
      end
      return @schema.name
    end
    
    def resourceNameHtml
      return "#{@name}.html"
    end
    
    def imports
      return @importedOntology ? @importedOntology.imports : []
    end

    #
    # See DOWL::Individual::classWithURI(uri)
    #    
    def classWithURI(uri)
      return @importedOntology ? @importedOntology.classWithURI(uri) : nil
    end

  end
end
