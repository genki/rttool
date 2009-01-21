#!/usr/bin/ruby
require 'rt/w3m'
require 'rt/rt2html-lib'

module RT
  class RT2TXTVisitor < RT2HTMLVisitor
    OUTPUT_SUFFIX = "txt"
    INCLUDE_SUFFIX = ["txt"]
    
    def visit(parsed)
      W3M::html2txt(super)
    end
  end                           # RT2TXTVisitor
end
$Visitor_Class = RT::RT2TXTVisitor
