require 'rubygems'
require 'rake/gempackagetask'

GEM_NAME = "rttool"
GEM_VERSION = "1.0.2"
AUTHOR = "rubikitch"
EMAIL = ""
HOMEPAGE = "http://www.rubyist.net/~rubikitch/computer/rttool/"
SUMMARY = "Simple table generator"

spec = Gem::Specification.new do |s|
  s.rubyforge_project = 'rttool'
  s.name = GEM_NAME
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "GPL"]
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.executables = %w(rt2 rdrt2)
  #s.add_dependency('merb', '>= 1.0.7.1')
  s.bindir = 'bin/rt'
  s.require_path = 'lib'
  s.files = %w(GPL README Rakefile) + Dir.glob("{lib,spec}/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Create a gemspec file"
task :gemspec do
  File.open("#{GEM_NAME}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end
