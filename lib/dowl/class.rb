module DOWL
  class Class < DOWL::LabelledDocObject
    include Comparable

    attr_reader :resource
    attr_reader :sub_classes
    attr_reader :associations

    private
    def initialize(resource, schema)
      super(resource, schema)
      @super_classes = nil
      @sub_classes = nil
      @associations = nil
    end

    public

    def Class.withUri(resource, schema)
      if resource.anonymous?
        warn "WARNING: Ignoring class with uri #{resource.to_s}"
        return
      end
      klass = schema.classes[resource.to_s]
      if klass
        return klass
      end
      klass = Class.new(resource, schema)
      schema.classes[resource.to_s] = klass
      puts "Created class #{klass.short_name}"
      return klass
    end

    public

    def see_alsos()
      links = []
      @schema.model.query(
      RDF::Query::Pattern.new(@resource, DOWL::Namespaces::RDFS.seeAlso)
      ) do |statement|
        links << statement.object.to_s
      end
      return links
    end

    public

    def super_classes()
      if not @super_classes.nil?
        return @super_classes
      end

      @super_classes = []

      @schema.model.query(
      RDF::Query::Pattern.new(@resource, DOWL::Namespaces::RDFS.subClassOf)
      ) do |statement|
        #
        # Only look at statements like these:
        #
        # <rdfs:subClassOf rdf:resource="<uri>"/>
        #
        # And ignore statements like these:
        #
        # <rdfs:subClassOf>
        #   <owl:Restriction>
        #     <owl:onProperty rdf:resource="<uri>"/>
        #     <owl:allValuesFrom rdf:resource="<uri>"/>
        #   </owl:Restriction>
        # </rdfs:subClassOf>
        #
        if statement.object.uri?
          superClass = Class.withUri(statement.object, @schema)
          if superClass
            if superClass != self
              @super_classes << superClass
            end
          else
            warn "WARNING: Could not find super class #{statement.object.to_s}"
          end
        end
      end
      return @super_classes
    end

    public

    def hasSuperClasses?
      return ! super_classes.empty?()
    end

    public

    def hasSuperClassesInSchema?
      super_classes.each() do |klass|
        if @schema.classes.include?(klass.uri)
          return true
        end
      end
      return false
    end

    public

    def sub_classes()
      if not @sub_classes.nil?
        @sub_classes.each do |subclass|
          puts "Returning subclass of #{short_name}: #{subclass.short_name}"
        end
        return @sub_classes
      end
      @sub_classes = []

      @schema.model.query(
      RDF::Query::Pattern.new(nil, DOWL::Namespaces::RDFS.subClassOf, @resource)
      ) do |statement|
        subClass = Class.withUri(statement.object, @schema)
        if subClass
          if subClass != self
            @sub_classes << subClass
          end
        else
          warn "WARNING: Could not find sub class of #{short_name} with uri #{statement.object.to_s}"
        end
      end
      @sub_classes.sort! { |x,y| x <=> y }
      @sub_classes.each do |subclass|
        puts "Returning subclass #{short_name}: #{subclass.short_name}..."
      end
      return @sub_classes
    end

    public

    def hasSubClasses?
      return ! sub_classes.empty?()
    end

    public

    def associations()
      if not @associations.nil?
        return @associations
      end
      @associations = Set.new

      if @schema.options.verbose
        puts "Searching for associations of class #{short_name}"
      end

      query = RDF::Query.new do
        pattern [:property, DOWL::Namespaces::RDFS.domain, @resource]
        pattern [:property, RDF.type, DOWL::Namespaces::OWL.ObjectProperty]
        pattern [:property, DOWL::Namespaces::RDFS.range, :range]
      end
      solution = query.execute(@schema.model)
      if @schema.options.verbose
        puts " - Found #{solution.count} solutions"
      end
      solution.distinct!
      if @schema.options.verbose
        puts " - Found #{solution.count} distinct solutions"
      end

      solution.each do |solution|
        property = solution[:property]
        range = solution[:range]
        puts " - Found Association from #{short_name} to #{@schema.prefixedUri(range)}: #{@schema.prefixedUri(property)}"
        rangeClass = Class.withUri(range, @schema)
        puts "   - Found this class for it: #{rangeClass}"
        if rangeClass
          @associations << Association.new(property, @schema, self, rangeClass)
        end
      end
      return @associations
    end

  end

  class Association < DOWL::LabelledDocObject

    attr_reader :domainClass
    attr_reader :rangeClass
    attr_reader :property
    def initialize(resource, schema, domainClass, rangeClass)
      super(resource, schema)
      @domainClass = domainClass
      @rangeClass = rangeClass
    end

    def hash
      "#{@domainClass.uri},#{@rangeClass.uri},#{@propery}".hash
    end

    def label
      return short_name
    end
    
    def addAsGraphVizEdge(graph, nodes)
      
      domainClassNode = nodes[@domainClass.uri]
      rangeClassNode = nodes[@rangeClass.uri]
        
      graph.add_edges(domainClassNode, rangeClassNode, :label => label)
    end
  end

end