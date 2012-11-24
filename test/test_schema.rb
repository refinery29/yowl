$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'yowl'
require 'test/unit'

class SchemaTest < Test::Unit::TestCase
  
  def test_cannot_create_from_nil_file
      assert_raise RuntimeError do
        YOWL::Schema.create_from_file(nil) 
      end
  end
  
  def test_create_from_file
    file = "tests/input/example.ttl"
    YOWL::Schema.create_from_file(File.expand_path(file))     
  end
  
  def test_read_classes_from_sample()
    file = "tests/input/example.ttl"
    schema = YOWL::Schema.create_from_file(File.expand_path(file))     
    classes = schema.classes()
    assert_not_nil classes
    assert_equal(2, classes.length)
  end
  
  def test_identify_owl_classes()    
    model = RDF::Graph.new()
    model << RDF::Statement.new( RDF::URI.new("http://www.example.com/"), RDF.type, YOWL::Namespaces::OWL.Class)
    schema = YOWL::Schema.new(model)
    assert_equal(1, schema.classes.length)
  end

  def test_identify_rdf_classes()
    model = RDF::Graph.new()
    model << RDF::Statement.new( RDF::URI.new("http://www.example.com/"), RDF.type, YOWL::Namespaces::RDFS.Class)
    schema = YOWL::Schema.new(model)
    assert_equal(1, schema.classes.length)
  end
  
end
