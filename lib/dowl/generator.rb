module DOWL

  class Generator
    
    def initialize(repository, options)
      @options = options
      @repository = repository
    end
    
    private
    def generateOntologyHtmlFiles()
      @repository.schemas.each() do |schema|
        generateOntologyHtmlFile(schema)
      end
    end
    
    private
    def generateOntologyHtmlFile(schema)
      if @options.verbose
        puts "Generating documentation for ontology #{schema.ontology.title}"
      end
      
      introduction = @introduction
      repository = @repository
      
      b = binding
      
      ontologyFile = File.join(@options.output_dir, "ontology/#{schema.name}.html")
      if @options.verbose
        puts "Generating #{ontologyFile}"
      end
      File.open(ontologyFile, 'w') do |file|
        file.write(@options.templates['ontology'].result(b))
      end
    end
    
    private
    def generateHtmlFile(templateName_)
      
      template = @options.templates[templateName_]
      
      if template.nil?
        puts "Not generating #{templateName_}.html since #{templateName_} template could not be found."
        return
      end
      fileName = File.join(@options.output_dir, '#{templateName_}.html')
      if @options.verbose
        puts "Generating #{fileName}"
      end
      
      repository = @repository
      schemas = @repository.schemas
      ontologies = @repository.ontologies()
      
      b = binding
      
      File.open(fileName, 'w') do |file|
        file.write(template.result(b))
      end
    end    
    
    public
    def run()
      generateHtmlFile('index')
      generateHtmlFile('overview')
      generateHtmlFile('introduction')
      generateHtmlFile('import-diagram')
      generateOntologyHtmlFiles()
    end
  end  
end
