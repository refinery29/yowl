require 'rake'
require 'rake/gempackagetask'
#require 'rubygems/package_task'
require 'rake/rdoctask'
#require 'rdoc/task'
require 'rake/testtask'
require 'rake/clean'

NAME = "dowl"
VER = "0.3"

RDOC_OPTS = ['--quiet', '--title', 'dowl Reference', '--main', 'README']

PKG_FILES = %w( README Rakefile CHANGES ) + 
  Dir.glob("{bin,doc,tests,examples,lib}/**/*")

CLEAN.include ['*.gem', 'pkg']  
SPEC =
  Gem::Specification.new do |s|
    s.name = NAME
    s.version = VER
    s.platform = Gem::Platform::RUBY
    s.required_ruby_version = ">= 1.8.5"    
    s.has_rdoc = true
    s.extra_rdoc_files = ["README", "CHANGES"]
    s.rdoc_options = RDOC_OPTS
    s.summary = "dowl OWL/RDF doc generator"
    s.description = s.summary
    s.author = "Leigh Dodds"
    s.email = 'leigh.dodds@talis.com'
    s.homepage = 'http://github.com/ldodds/dowl'
    s.files = PKG_FILES
    s.require_path = "lib" 
    s.bindir = "bin"
    s.executables = ["dowl"]
    s.test_file = "tests/ts_dowl.rb"
    s.add_dependency("mocha", ">= 0.9.5")
    s.add_dependency("rdf-raptor", ">= 0.4.0")
  end
      
Rake::GemPackageTask.new(SPEC) do |pkg|
    pkg.need_tar = true
end

Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir = 'doc/rdoc'
    rdoc.options += RDOC_OPTS
    rdoc.rdoc_files.include("README", "CHANGES", "lib/**/*.rb")
    rdoc.main = "README"
    
end

Rake::TestTask.new do |test|
  test.test_files = FileList['tests/tc_*.rb']
end

desc "Install from a locally built copy of the gem"
task :install do
  sh %{rake package}
  sh %{sudo gem install pkg/#{NAME}-#{VER}}
end

desc "Uninstall the gem"
task :uninstall => [:clean] do
  sh %{sudo gem uninstall #{NAME}}
end
