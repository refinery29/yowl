module DOWL
  
  class DocObject
    
    attr_reader :resource
    attr_reader :schema
    
    def initialize(resource, schema)
      @resource = resource
      @schema = schema
      if (@resource and not @resource.uri?)
        raise "ERROR: Instantiating an object with a non-URI resource: #{@resource.to_s} (#{@resource.inspect})"
      end
    end  
    
    def repository
      return @schema.repository
    end
    
    def uri 
      return @resource ? @resource.to_s : nil
    end
    
    def hasUri?(uri)
      return @resource == uri
    end   

    def short_name()
      return @schema.prefixedUri(uri)
    end

    def escaped_short_name()
      str = short_name()
      # TODO: optimize this into one pattern
      str = str.gsub("://", "_")
      str = str.gsub(".", "_")
      str = str.gsub(",", "_")
      str = str.gsub("/", "_")
      return str
    end
    
    def escaped_uri()
      str = short_name().to_s
      # TODO: optimize this into one pattern
      str = str.gsub("://", "__")
      str = str.gsub(".", "_")
      str = str.gsub("/", "_")
      str = str.gsub("#", "_")
      str = str.gsub(":", "_")
      str = str.gsub(",", "_")
      return str
    end
    
    def to_s()
      return short_name()
    end    
    
    def get_literal(property)
      return @resource ? @schema.model.first_value(RDF::Query::Pattern.new(@resource, property)) : nil
    end
    
    def ontology
      return @schema.ontology ? @schema.ontology : nil
    end
    
  end
  
  class LabelledDocObject < DOWL::DocObject
    
    def initialize(resource, schema)
       super(resource, schema)
    end
    
    def label()
      label = get_literal(DOWL::Namespaces::RDFS.label)
      return label.nil? ? short_name() : label
    end
    
    def hasDifferentLabel?
      #puts "****\n- #{short_name().sub(/.+:/, '')}\n- #{label}\n****"
      #return short_name().sub(/.+:/, '') != label()
      return short_name() != label()
    end
        
    def comment()
      return get_literal(DOWL::Namespaces::RDFS.comment)
    end
    
    def hasComment?
      comment = comment()
      return (comment and not comment.empty?)
    end
    
    def status()      
      return get_literal(DOWL::Namespaces::VS.status)
    end

    def <=>(other)
      return label().downcase <=> other.label().downcase
    end    
    
  end
  
  class GraphvizUtility
  
  	def GraphvizUtility.setDefaults(g)
  	  
      g[:rankdir] = "BT"
        
      g.node[:peripheries] = 0
      g.node[:style] = "rounded,filled"
      g.node[:fillcolor] = "#0861DD" 
      g.node[:fontcolor] = "white"
      g.node[:fontname] = "Verdana" 
      g.node[:shape] = "box"
      g.node[:fontsize] = 8
      g.node[:fixedsize] = false # Classes with long names need wider boxes
      g.node[:width] = 1
      g.node[:height] = 0.4
        
      g.edge[:fontname] = "Verdana"
      g.edge[:fontsize] = 6
      g.edge[:fontcolor] = "#0861DD"
      g.edge[:labeldistance] = 2
        
      return g
  	end
  	
  	def GraphvizUtility.embeddableSvg(g)
  	  puts "Generated Dot is:"
      puts g.output(:dot => String)

  	  svg = g.output(:svg => String)
      index = svg.index("<svg")
      return index ? svg[index..-1] : svg
    end
  end
  
end
