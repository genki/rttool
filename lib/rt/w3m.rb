#!/usr/bin/ruby
=begin
w3m.rb
$Id: w3m.rb 597 2005-10-18 21:03:12Z rubikitch $

--- W3M.w3m(url, options='-e')
      invoke w3m.
--- W3M.html2txt(htmlstr, options='-e')
      convert htmlstr to plain text.
--- W3M.source(url, options='-e')
      get the source.
=end

module W3M

  module_function

  def external_filter (str, prog)
    require 'open3'

    pipe = Open3.popen3(prog)
    pipe[0] .print str
    pipe[0] .close
    pipe[1] .read
  end
  private_class_method :external_filter

  def w3m(url, option='-e')
    open("| w3m -dump #{option} #{url}").readlines.join
  end
  
  def html2txt(htmlstr, option='-e')
    external_filter(htmlstr, "w3m -dump -T text/html #{option}")
  end
  
  def source(url, option='')
    open("| w3m -dump_source #{option} #{url}").readlines.join
  end
end

if __FILE__ == $0
  s = W3M::source('http://www.ruby-lang.org')
  #print W3M::html2txt s

end
  
  
