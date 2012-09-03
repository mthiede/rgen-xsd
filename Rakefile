require 'rake/gempackagetask'
require 'rake/rdoctask'

DocFiles = [
  "README", "CHANGELOG", "MIT-LICENSE"]

RTextGemSpec = Gem::Specification.new do |s|
  s.name = %q{rgen-xsd}
  s.version = "0.2.0"
  s.date = Time.now.strftime("%Y-%m-%d")
  s.summary = %q{RGen XML schema support}
  s.email = %q{martin dot thiede at gmx de}
  s.homepage = %q{http://ruby-gen.org}
  s.description = %q{Derive RGen/ECore metamodels from XML schema and load/store XML documents conforming to the schema as RGen models}
  s.authors = ["Martin Thiede"]
  s.add_dependency('rgen', '>= 0.6.0')
  gemfiles = Rake::FileList.new
  gemfiles.include("{lib,test}/**/*")
  gemfiles.include(DocFiles)
  gemfiles.include("Rakefile") 
  gemfiles.exclude(/\b\.bak\b/)
  s.files = gemfiles
  s.rdoc_options = ["--main", "README", "-x", "test"]
  s.extra_rdoc_files = DocFiles
end

Rake::RDocTask.new do |rd|
  rd.main = "README"
  rd.rdoc_files.include(DocFiles)
  rd.rdoc_files.include("lib/**/*.rb")
  rd.rdoc_dir = "doc"
end

RTextPackageTask = Rake::GemPackageTask.new(RTextGemSpec) do |p|
  p.need_zip = false
end	

task :prepare_package_rdoc => :rdoc do
  RTextPackageTask.package_files.include("doc/**/*")
end

task :release => [:prepare_package_rdoc, :package]

task :clobber => [:clobber_rdoc, :clobber_package]

