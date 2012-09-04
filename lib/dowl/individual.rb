module DOWL
  #
  # Represents an Individual defined in the schema
  #  
  class Individual < DOWL::LabelledDocObject
    
    #
    # This label is a bit different than the one in the base class as this one
    # gets its prefix stripped, if there is one.
    #
    attr_reader :label
    #
    # The prefix to be used for the URI of this Individual, if defined, nil if it isn't
    #
    attr_reader :prefix
    attr_reader :types
    attr_reader :classes
    
    def initialize(resource, schema)
      super(resource, schema)
      @label = init_label
      @prefix = init_prefix
      @types = init_types
      @classes = init_classes
    end
    
    def init_label
      label = get_literal(DOWL::Namespaces::RDFS.label)
      if label
        return label
      end 
      label = short_name
      label = label.sub(/(.*)\s*:/, "")
      label = label.gsub("_", " ")

      return label
    end
    
    def init_prefix
      name = short_name
      return name.include?(':') ? short_name.sub(/:\s*(.*)/, "") : nil
    end
    
    def init_types
      types = []
      @schema.model.query(
        RDF::Query::Pattern.new(@resource, RDF.type)
      ) do |statement|
        if statement.object == DOWL::Namespaces::OWL.NamedIndividual
          next
        end
        types << statement.object
        puts "Found Type #{statement.object.to_s} for #{label}"
      end
      return types
    end
    
    def init_classes
      classes = []
      ont = ontology
      @types.each do |type|
        if ont
          klass = ontology.classWithURI(type)
        else
          klass = @schema.classInSchemaWithURI(type)
        end
        if klass
          classes << klass
        else
          puts "WARNING: Could not find Class definition for URI #{type.to_s}"
        end
      end
      return classes
    end
    
    public
    #
    # Add the current Individual as a GraphViz node to the given collection of nodes
    # and to the given graph. Return the collection of nodes.
    #    
    def addAsGraphvizNode (nodes, graph)
      if @schema.options.verbose
        puts "- Processing Individual #{label}"
      end
      #
      # No need to add a node twice
      #
      if nodes.has_key?(uri)
        return nodes
      end
      node = graph.add_nodes(escaped_uri)
      #node.URL = "#individual#{short_name}"
      
      if prefix
        node.label = "#{label}\n(#{prefix})"
      else
        node.label = label
      end 
      #if hasComment?
      #  node.tooltip = comment
      #end
      nodes[uri] = node
      return nodes
    end    
    
    public
    #
    # Generate a diagram for each Individual
    #
    def asSvg
      if @schema.options.verbose
        puts "Generating SVG for Individual #{short_name}"
      end
    
      g = GraphvizUtility.setDefaults(GraphViz.new(:G, :type => :digraph))
      g[:rankdir] = "LR"
      g.node[:fixedsize] = false
      
      nodes = Hash.new
      edges = Hash.new
      nodes = addAsGraphvizNode(nodes, g)
      
      individualNode = nodes[0]
      
      @classes.each do |klass|
        nodes = klass.addAsGraphvizNode(nodes, g)
        klassNode = nodes[klassNode.uri]
        g.add_edges(individualNode, klassNode)
      end
      
      return GraphvizUtility.embeddableSvg(g)
    end
  end
end
