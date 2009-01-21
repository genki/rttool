# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rttool}
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["rubikitch"]
  s.bindir = %q{bin/rt}
  s.date = %q{2009-01-22}
  s.description = %q{Simple table generator}
  s.email = %q{}
  s.executables = ["rt2", "rdrt2"]
  s.extra_rdoc_files = ["README", "GPL"]
  s.files = ["GPL", "README", "Rakefile", "lib/PATHCONV", "lib/rd", "lib/rd/rt-filter.rb", "lib/rt", "lib/rt/rt2html-lib.rb", "lib/rt/rt2txt-lib.rb", "lib/rt/rtparser.rb", "lib/rt/rtvisitor.rb", "lib/rt/w3m.rb", "bin/rt/rt2", "bin/rt/rdrt2"]
  s.has_rdoc = true
  s.homepage = %q{http://www.rubyist.net/~rubikitch/computer/rttool/}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rttool}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Simple table generator}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
