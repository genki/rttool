#!/usr/bin/env ruby
require 'test/unit'
require 'rttool-sub'

module Chdir
  def pushd
    @pwd = Dir.pwd
    Dir.chdir File.dirname(File.expand_path(__FILE__))
  end

  def popd
    Dir.chdir @pwd
  end
  def setup
    pushd
  end
end

class TestRTtool < Test::Unit::TestCase
=begin eev
= How to make test files
 (eecd2)
cd ../examples/; rt2 -r rt/rt2html-lib test1.rt > test1.html
cd ../examples/; rt2 -r rt/rt2html-lib test2.rt > test2.html
cd ../examples/; rt2 -r rt/rt2html-lib escape.rt > escape.html
cd ../examples/; rd2  --with-part=RT:rt rttest.rd > rttest.html
=end
  include Chdir
  def teardown
    rt2html
    popd
  end

  def rt2html
    @html = "#{@name}.html"
    @rt = "#{@name}.rt"
    AssertFile.basedir = "../examples"
    AssertFile.transaction(@html) do |html|
      system_safe "cd ../examples; ruby -I../lib ../bin/rt/rt2 -r rt/rt2html-lib #{@rt} > #{html}"
    end
  end

#
  def test__test1
    # (find-filez "test1.rt test1.html" "../examples/")
    @name = "test1"
  end
#

  def test__test2
    # (find-filez "test2.rt test2.html" "../examples/")
    @name = "test2"
  end

  def test__escape
    # (find-filez "escape.rt escape.html" "../examples/")
    @name = "escape"
  end

end


class TestRDRT2 < Test::Unit::TestCase

  include Chdir

  def teardown
    rdrt2
    popd
  end

  def rdrt2
    ENV['RUBYLIB'] = "../lib"
    @html = "#{@name}.html"
    @rd = "#{@name}.rd"
    AssertFile.basedir = "../examples"
    AssertFile.transaction(@html) do |html|
      system_safe "cd ../examples; ruby ../bin/rt/rdrt2  #{@rd} > #{html}"
    end
  end

  def test_rttest
    # (find-filez "rttest.rd rttest.html" "../examples/")
    @name = "rttest"
  end
  
  
end
