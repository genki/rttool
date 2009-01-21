#!/usr/bin/ruby
require 'rt/rtparser'
require 'test/unit'
require 'nkf'

include RT

class RTCellTest < Test::Unit::TestCase
  def test_equal
    assert_equal(RTCell::new(""), RTCell::new("", :left))
    assert_equal(RTCell::new(""), RTCell::new("", :right))
    assert_equal(RTCell::new(""), RTCell::new("", :center))
  end
  def test_align
    assert_equal(:left,   RTCell::new("value").align)
    assert_equal(:left,   RTCell::new("value", :left).align)
    assert_equal(:left,   RTCell::new("1", :left).align)
    assert_equal(:center, RTCell::new("value", :center).align)
    assert_equal(:center, RTCell::new("1.90", :center).align)
    assert_equal(:right,  RTCell::new("1.1kg").align)
    assert_equal(:right,  RTCell::new("value", :right).align)
    assert_raises(RuntimeError){ RTCell::new("value", :error)}
  end
end

                 
module CellShortcut
  def c(x)
    RTCell::new(x,:center)
  end

  def l(x)
    RTCell::new(x, :left)
  end

  def r(x)
    RTCell::new(x, :right)
  end
  private :c, :l, :r
end

class RTParserTest < Test::Unit::TestCase
  def setup
    @x = RTParser::new
  end
    
  def test_blocks
    blocks = lambda{|str| @x.make_blocks(str).blocks}

    # no block
    assert_equal([[], [], []], blocks.call(""))
    # 1 block: body
    assert_equal([[], [], ["body"]], blocks.call("body"))
    # 2 blocks: config body
    assert_equal([["config"], [], ["body"]] ,blocks.call("config\n\nbody"))
    # 3 blocks: config header body
    assert_equal([["config1", "config2"], ["header"], ["body"]], blocks.call("config1\nconfig2\n\nheader\n\nbody"))
    assert_raises(RuntimeError){ blocks.call("config\n\nheader\n\nbody\n\nextra")}
  end
  
  def test_parse_config
    dc = RTParser::DefaultConfig
    pc = lambda{|config_line| @x.parse_config(config_line).config}
    assert_equal(dc, pc.call([]))
    assert_equal(dc.update("p1"=>"v1", "p2"=>"v2", "p3"=>"v3"),
                 pc.call(["p1 = v1", "#comment", " p2= v2", "p3=v3"]))
    assert_equal(dc.update("p1"=>"\t"), pc.call(["p1 = \t"]))
    assert_raises(RuntimeError){ pc.call(["p1 = v1", "error"])}
  end
  
  include CellShortcut

  def test_parse_header
    ph = lambda{|header_line| @x.parse_header(header_line).header}
    assert_equal([ [c(""),  c("wide"),   "==",  c("std")],
                   [c("x"), c("1"),    c("x2"), c("tall")],
                   [c(""),  c("y1"),   c("y2"),   "||"]],
                 ph.call([ "    , wide, == , std",
                           "#comment",
                           " x  , 1   ,  x2, tall",
                           "  ,   y1  ,  y2, ||  "]))
    
    assert_equal([[c(""), c("x"), c("y"), c("z")]],
                 ph.call(["\t,x\t ,y \t,z"]))
    assert_equal([[c(""), c("X"), c("Y"), c("Z")]],
                 ph.call(["\tX\t\tY\tZ"]))
    assert_equal([[c(""), c("1999"), c(""), c("2000"), c("")]],
                 ph.call([",\t1999,\t,\t2000,"]))

    assert_raises(RuntimeError){
                 ph.call([ "  , wide,  == , std",
                           "#comment",
                           "  , x1  ,  differenterror ",
                           ",   y1  ,  y2,  ==   "])}
  end
  
  def test_parse_body
    pb = lambda{|body_line| @x.parse_body(body_line).body}
    assert_equal([ [c(""), l("wide"),    "==",  r("-101")],
                   [c(""), r("2.2kg"), r("2L"), l("tall")],
                   [c(""), l("y1"),    l("y2"),   "||"],
                   [l("a"),l("b"),     c(""),   c("")]],
                 pb.call([ "#comment-----------",
                           "  , wide,  == , -101",
                           "  , 2.2kg,  2L, tall",
                           ",   y1  ,   y2, ||",
                           "a, b,,"]))
  end
  
  def test_calc_span
    tbl = [ [c(""), l("wide"),    "==",    "=="],
            [c(""), r("2.2kg"), r("2L"), l("tall")],
            [c(""), l("y1"),    l("y2"),   "||"]]

    @x.calc_span(tbl)
    assert_equal(1, tbl[0][0].rowspan)
    assert_equal(1, tbl[0][0].colspan)
    assert_equal(3, tbl[0][1].colspan)
    assert_equal(2, tbl[1][3].rowspan)
  end
    
  
    
end

class RTParseTest < Test::Unit::TestCase
  include CellShortcut
  module CRLF
    include NKF
    def to_unix(str)
      nkf("-Lu", str)
    end

    def to_dos(str)
      nkf("-Lw", str)
    end

    def to_mac(str)
      nkf("-Lm", str)
    end
  end

  def setup
    @rt = <<-END
delimiter = ;
rowspan = @

    ; x ; @

z   ; 1 ; 2
zz  ; 3 ; 4
END
  end

  def check
    assert_equal(';', @x.config['delimiter'])
    assert_equal('@', @x.config['rowspan'])
    assert_equal([[c(""), c("x"), "@"]], @x.header)
    assert_equal([ [l("z"), r("1"), r("2")],
                   [l("zz"),r("3"), r("4")],
                 ], @x.body)
  end
                 
  include CRLF

  def test_unix
    @x = RTParser::parse(to_unix(@rt))
    check
  end

  def test_dos
    @x = RTParser::parse(to_dos(@rt))
    check
  end

  def test_mac
    @x = RTParser::parse(to_mac(@rt))
    check
  end

end


class RTParseWithEscapeTest
  def test__parse__with_escape1
    x = RTParser::parse <<-'END'
delimiter = ;
escape = %

%z   ; %;1 ; 2
END
    
    assert_equal(';', x.config['delimiter'])
    assert_equal([ [l("%z"), l(";1"), r("2")],], x.body)
  end
                 
  def test__parse__with_escape2
    x = RTParser::parse <<-'END'
delimiter = ;
escape = \

\z   ; \;1 ; 2
END
    
    assert_equal(';', x.config['delimiter'])
    assert_equal([ [l("\\z"), l(";1"), r("2")],], x.body)
  end
                 
end
