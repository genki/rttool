require 'tempfile'
$RC["filter"]["rt"] = Filter.new(:target) do |inn, out|
  ext = $Visitor_Class.const_get('OUTPUT_SUFFIX')
  if ext == 'txt'
    ext = 'html'
  end
  tmpf = Tempfile.new("rt")
  tmpf.write inn.read
  tmpf.close
  out.print `rt2 -r rt/rt2#{ext}-lib #{tmpf.path}`
end
