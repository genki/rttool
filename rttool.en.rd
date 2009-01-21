=begin


= RTtool

##### [whats new]
== What's new

=== [2006/09/20] 1.0.2 released
* Bugfix about linefeed.

=== [2005/10/28] 1.0.1 released
* RTtool does not use .rd2rc anymore.
=== [2005/10/26] 1.0.0 released

* Escape.
* English document.
* Removed Ruby-1.8 warning.

##### [/whats new]

##### [abstract]
== Abstract

RT is a simple and human-readable table format.
RTtool is a converter from RT into various formats.
RT can be incorporated into RD.

At this time, RTtool can convert RT into HTML and plain text.
To convert into plain text, you need ((<w3m|URL:http://w3m.sourceforge.net/>)).

##### [/abstract]
== Environment

##### [install]
== Install
Please execute the following commands.

    ruby -ropen-uri -e 'URI("http://www.rubyist.net/~rubikitch/archive/rttool-1.0.2.tar.gz").read.display' > rttool-1.0.2.tar.gz
  tar xzvf rttool-1.0.2.tar.gz


When you failed, please download it from the next link.

* ((<rttool-1.0.2.tar.gz|URL:http://www.rubyist.net/~rubikitch/archive/rttool-1.0.2.tar.gz>))

Then, install it.

  cd rttool-1.0.2
  ruby setup.rb config
  ruby setup.rb setup
  ruby setup.rb install


##### [/install]

== RT Syntax
* RT consists of three Blocks.
  :ConfigBlock
     ConfigBlock consist of groups of "attribute = value".
     The following examples has (({caption})) attribute.
     ConfigBlock can be omitted.
  :HeaderBlock
    A part of THEAD by HTML.
    HeaderBlock sets a header of the table.
    A header is located at the center.
    HeaderBlock can be omitted.
  :BodyBlock
    A part of TBODY by HTML.
    BodyBlock sets data of the table.
    A number is located at the right and others are located at left.
* The default delimiter on HeaderBlock and BodyBlock is a comma or a Tab.
  *  It is not necessary to be always harmonious with an upper line.
  *  Arbitrary character can be a delimiter by changing (({delimiter})) attribute.
* (({==})) stretches the left column. (colspan)
* (({||})) stretches the upper row. (rowspan)

== Attributes
In ConfigBlock, these attributes can be set.

:caption
  The caption of the table.

:delimiter
  The delimiter of the table.

:rowspan
  A string which stretches the left column. (defalut: (({==})))

:colspan
  A string which stretches the upper row. (default: (({||})))
  
:escape
  An escape character.
  This attribute is disabled by default.

== Examples

=== The Easiest RT
  $ cat examples/easiest.rt
  1, 2, 3
  4, 5, 6
  7, 8, 9

  $ rt2 examples/easiest.rt
  игибииибииибид
  ив 1ив 2ив 3ив
  изибилибилибий
  ив 4ив 5ив 6ив
  изибилибилибий
  ив 7ив 8ив 9ив
  ижибикибикибие

  $ rt2 -r rt/rt2html-lib examples/easiest.rt
  <!-- setup -->
  <table border="1">
  <!-- setup end -->
  
  <!-- Header -->
  <!-- Header end -->
  
  <!-- Body -->
  <tbody>
  <tr><td align="right">1</td><td align="right">2</td><td align="right">3</td></tr>
  <tr><td align="right">4</td><td align="right">5</td><td align="right">6</td></tr>
  <tr><td align="right">7</td><td align="right">8</td><td align="right">9</td></tr>
  </tbody>
  <!-- Body end -->
  
  <!-- teardown -->
  </table>
  <!-- teardown end -->
  



=== Use the Escape Attribute
  $ cat examples/escape.rt
  delimiter = ;
  escape = \
  
  \z   ; \;1 ; 2

  $ rt2 examples/escape.rt
  игибииибииибид
  ив\zив;1ив 2ив
  ижибикибикибие

  $ rt2 -r rt/rt2html-lib examples/escape.rt
  <!-- setup -->
  <table border="1">
  <!-- setup end -->
  
  <!-- Header -->
  <!-- Header end -->
  
  <!-- Body -->
  <tbody>
  <tr><td align="left">\z</td><td align="left">;1</td><td align="right">2</td></tr>
  </tbody>
  <!-- Body end -->
  
  <!-- teardown -->
  </table>
  <!-- teardown end -->
  



=== More Complex RT
  $ cat examples/test1.rt
  caption = Test Table
  
       , Human, == , Dog , ==
  ||  , M  , F ,M,F
  
    x  , 1.0 , 2.0, 1.1, 1.2
    y  , 0.4 , 0.5, 0.3, 0.1

  $ rt2 examples/test1.rt
            Test Table
  игибииибибибибибииибибибибибид
  ив  ив  Human   ив   Dog    ив
  ив  изибибииибибилибибииибибий
  ив  ив M  ив F  ив M  ив F  ив
  изибилибибилибибилибибилибибий
  ивx ив 1.0ив 2.0ив 1.1ив 1.2ив
  изибилибибилибибилибибилибибий
  ивy ив 0.4ив 0.5ив 0.3ив 0.1ив
  ижибикибибикибибикибибикибибие

  $ rt2 -r rt/rt2html-lib examples/test1.rt
  <!-- setup -->
  <table border="1">
  <caption>Test Table</caption>
  <!-- setup end -->
  
  <!-- Header -->
  <thead>
  <tr><th rowspan="2"></th><th colspan="2">Human</th><th colspan="2">Dog</th></tr>
  <tr><th>M</th><th>F</th><th>M</th><th>F</th></tr>
  </thead>
  <!-- Header end -->
  
  <!-- Body -->
  <tbody>
  <tr><td align="left">x</td><td align="right">1.0</td><td align="right">2.0</td><td align="right">1.1</td><td align="right">1.2</td></tr>
  <tr><td align="left">y</td><td align="right">0.4</td><td align="right">0.5</td><td align="right">0.3</td><td align="right">0.1</td></tr>
  </tbody>
  <!-- Body end -->
  
  <!-- teardown -->
  </table>
  <!-- teardown end -->
  



=== RT Included by RD (RD/RT)
  $ cat examples/rttest.rd
  =begin
  = Sample RD/RT
  
  This RD contains a table.
  It is so-called RD/RT.
  
  =end
  =begin RT
  caption = Test Table
  
       , Human, == , Dog , ==
  ||  , M  , F ,M,F
  
    x  , 1.0 , 2.0, 1.1, 1.2
    y  , 0.4 , 0.5, 0.3, 0.1
  
  =end
  =begin
  It is simple.
  =end

  $ rdrt2 examples/rttest.rd | w3m -dump -T text/html
  = Sample RD/RT
  
  This RD contains a table. It is so-called RD/RT.
  
            Test Table
  игибииибибибибибииибибибибибид
  ив  ив  Human   ив   Dog    ив
  ив  изибибииибибилибибииибибий
  ив  ив M  ив F  ив M  ив F  ив
  изибилибибилибибилибибилибибий
  ивx ив 1.0ив 2.0ив 1.1ив 1.2ив
  изибилибибилибибилибибилибибий
  ивy ив 0.4ив 0.5ив 0.3ив 0.1ив
  ижибикибибикибибикибибикибибие
  
  It is simple.
  



== License
Ruby's
=end
