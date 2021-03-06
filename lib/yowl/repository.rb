module YOWL
  
  class Repository
    
    attr_reader :schemas
    attr_reader :options

    def initialize(options)
      @options = options
      
      init_schemas()
    end
    
    private
    def init_schemas()
      @schemas = {}
        
      @options.ontology_file_names.each() do | ontology_file_name |
        if options.verbose
          puts "Parsing #{ontology_file_name}"
        end
        schema = Schema.fromFile(ontology_file_name, self)
        if schema
          @schemas[schema.uri] = schema
          #puts "Registered schema with URI #{schema.uri}"
        end
      end
    end  
    
    public
    def ontologies()
      ontologies = @schemas.values.collect() { |schema|
        schema.ontology
      }
      return ontologies.sort { |x,y| x.short_name <=> y.short_name }
    end
 
    public
    def getSchemaForImport(import_)
      begin
        return @schemas[import_.uri]
      rescue => exception
        puts exception.backtrace
      end
    end
       
    public
    def knowsImport(import_)
      return ! getSchemaForImport(import_).nil?
    end
    
    public
    def getSchemaNameForImport(import_)
      schema = getSchemaForImport(import_)
      return schema.nil? ? '' : schema.name
    end
    
    public
    def ontologiesAsSvg
      if @options.verbose
        puts "Generating SVG for Ontology Import Diagram"
      end

      g = GraphvizUtility.setDefaults(GraphViz.new(:G, :type => :digraph))
        
      nodes = {}
      ontologies.each() do |ontology|
        nodeID = ontology.escaped_uri
        node = g.add_nodes(nodeID)
        node.URL = ontology.resourceNameHtml
        node.label = ontology.short_name
        node.tooltip = ontology.commentOrLabel
        nodes[nodeID] = node
      end
     
      ontologies.each() do |ontology|
        if @options.verbose
          puts "- Processing ontology #{ontology.escaped_uri}"
        end
        ontology.imports.each() do |import|
          importNode = nodes[import.name]
          if importNode
            if @options.verbose
              puts "  - Processing import #{import.name}"
            end
            g.add_edges(nodes[ontology.short_name], importNode)
          else
            if @options.verbose
              puts "  - Processing import #{import.name}, not found"
            end
          end
        end
      end

      #puts g.to_dot()
      return GraphvizUtility.embeddableSvg(g)
    end
    
  end
end