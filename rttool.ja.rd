=begin


= RTtool

##### [whats new]
== 更新履歴
=== [2006/09/20] 1.0.2 released
*  改行コードがDOS, MACだとうまく動作しないバグを修正。

=== [2005/10/28] 1.0.1 released
*  .rd2rcを使わなくなった。
=== [2005/10/26] 1.0.0 released
*  エスケープできるようになった。英語のドキュメント付属。
*  Ruby1.8のwarningを削除。
  
=== [2001/11/15] 0.1.7 released
*  符号つきの数字でも右揃えにするようにした。
=== [2001/08/07] 0.1.6 released
*  空白セルの処理でのバグを対処。
=== [2001/07/17] 0.1.5 released
*  rt2html-lib.rb: captionが指定してないときはCAPTION要素をつけないように。
=== [2001/07/09] 0.1.4 released
*  あおきさんのsetup.rbを使用。 それに伴い、パッケージ構成を変更。
=== [2001/06/03] 0.1.3 released
*  rt2html-lib.rbにおいてタグを小文字に変更。これでXHTMLでも大丈夫。
  
##### [/whats new]

##### [abstract]
== 概要

RTtoolはシンプルな作表ツール。
RDの売りである((*可読性*))と((*さまざまなフォーマットに変換可能*))を継承し、
RDtoolの実験的機能ではあるがfilter機能によりRDと((*融合*))させることが可能である。
いってみれば((*兄弟みたいなものである。*))

今のところ、RTはHTMLとPlain text（要((<w3m|URL:http://w3m.sourceforge.net/>))）へ変換できる。
w3mのWindows版はCygwinしかないので、Windowsの人はCygwinを使う必要がある。
HTMLへの変換のみ必要ならばw3mは不要である。

設計の方もRDtoolと似せている。
parserとvisitorに分け、rt2html-lib.rbを作成。

##### [/abstract]


##### [install]
== インストール
以下のコマンドを実行。

    ruby -ropen-uri -e 'URI("http://www.rubyist.net/~rubikitch/archive/rttool-1.0.2.tar.gz").read.display' > rttool-1.0.2.tar.gz
  tar xzvf rttool-1.0.2.tar.gz


失敗する場合は次のリンクからダウンロード。

* ((<rttool-1.0.2.tar.gz|URL:http://www.rubyist.net/~rubikitch/archive/rttool-1.0.2.tar.gz>))

それから次のコマンドでインストール。

  cd rttool-1.0.2
  ruby setup.rb config
  ruby setup.rb setup
  ruby setup.rb install


##### [/install]

(1)パッケージにある rt ディレクトリを $LOAD_PATH の通ったディレクトリにコピーする。
   * (({require 'rt/rtparse'}))と使われるので。
(2)rt/rt2 コマンドを PATH の通ったディレクトリに移動する。
(3)rt/dot.rt.rd2rc
   * もし ~/.rd2rc というファイルが存在しなければ、 ~/.rd2rc にリネーム。
   * 存在するときは、差分を適宜設定する。
== RTの文法
* RTは3つのBlockで構成される
  :ConfigBlock
    「属性 = 値」の組からなる。
    以下の例では caption 属性を設定し、表題をつけている。
    このBlockは省略できる。
  :HeaderBlock
    HTMLでいうTHEADの部分。
    表のヘッダを設定する。
    ヘッダは中央揃えになる。
    このBlockも省略できる。
  :BodyBlock
    HTMLでいうTBODYの部分。
    データを記述する。
    数字は右揃え、それ以外は左揃えになる。
* HeaderBlock, BodyBlock の項目の区切は ((',')) かTabである。
  * 必ずしも上の行と揃っている必要はない。
    ただ、揃えた方が見やすいとはいえる。
  * 区切文字は delimiter 属性の値を変えることで任意の文字列にできる。
* (('=='))は左の列を伸ばす。
  HTMLでいうTH、TD要素のcolspan属性に影響。
  * rowspan 属性の値を変えることで任意の文字列にできる。
* (('||'))は上の行を伸ばす。
  HTMLでいうTH、TD要素のrowspan属性に影響。
  * colspan 属性の値を変えることで任意の文字にできる。

== 属性一覧
ConfigBlockでは次の属性が設定できる。

:caption
  表のタイトルを設定する。

:delimiter
  データの区切を指定する。

:rowspan
  左の列を伸ばす指定。（デフォルトは(({==}))）

:colspan
  上の行を伸ばす設定。（デフォルトは(({||}))）
  
:escape
  delimiterをデータに含める必要があるときにこの属性で指定された文字を前置する。
  デフォルトでは無効となっている。
== 例

=== 一番簡単なRT
値をカンマで区切るのが一番簡単なRT。

  $ cat examples/easiest.rt
  1, 2, 3
  4, 5, 6
  7, 8, 9

  $ rt2 examples/easiest.rt
  ┌─┬─┬─┐
  │ 1│ 2│ 3│
  ├─┼─┼─┤
  │ 4│ 5│ 6│
  ├─┼─┼─┤
  │ 7│ 8│ 9│
  └─┴─┴─┘

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
  



=== エスケープ
RTはdelimiterを自由に指定できるが、delimiterを地の文に含める必要があるとき、
* delimiterを別なものに置換するか
* 1.0.0で導入されたエスケープを使う

エスケープは、delimiter文字の前に置くことで、delimiterではなくて地の文とみなされる。

  $ cat examples/escape.rt
  delimiter = ;
  escape = \
  
  \z   ; \;1 ; 2

  $ rt2 examples/escape.rt
  ┌─┬─┬─┐
  │\z│;1│ 2│
  └─┴─┴─┘

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
  



=== ちょっと複雑なRT

  $ cat examples/test1.rt
  caption = Test Table
  
       , Human, == , Dog , ==
  ||  , M  , F ,M,F
  
    x  , 1.0 , 2.0, 1.1, 1.2
    y  , 0.4 , 0.5, 0.3, 0.1

  $ rt2 examples/test1.rt
            Test Table
  ┌─┬─────┬─────┐
  │  │  Human   │   Dog    │
  │  ├──┬──┼──┬──┤
  │  │ M  │ F  │ M  │ F  │
  ├─┼──┼──┼──┼──┤
  │x │ 1.0│ 2.0│ 1.1│ 1.2│
  ├─┼──┼──┼──┼──┤
  │y │ 0.4│ 0.5│ 0.3│ 0.1│
  └─┴──┴──┴──┴──┘

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
  



=== RDに埋め込む
さらに、RDに埋め込むこともできるのだ。
RTは((*RDではないのでRDのfilter機能を使う*))ことになる。
これで表つきのテキストを生成できる。
beginとendが煩雑なのはRDtoolの仕様なのでしょうがない。
コマンドラインが長くなるのでrdrt2というコマンドを用意。

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
  ┌─┬─────┬─────┐
  │  │  Human   │   Dog    │
  │  ├──┬──┼──┬──┤
  │  │ M  │ F  │ M  │ F  │
  ├─┼──┼──┼──┼──┤
  │x │ 1.0│ 2.0│ 1.1│ 1.2│
  ├─┼──┼──┼──┼──┤
  │y │ 0.4│ 0.5│ 0.3│ 0.1│
  └─┴──┴──┴──┴──┘
  
  It is simple.
  



== なぜにRT
* HTMLやLaTeXの表の書き方がちょいイラつく。
  * 読み書きしにくい。
* RDに表作成機能があればいいが、いろいろ弊害が。
  * RDの文法が複雑になる。
  * RDとして見辛くなる。
* RTの部分だけ独自に変更が可能。
* 俺がRDを愛してるから。
* 自分に合った表作成ツールがほしい。

== TODO
約6年、いろいろなことを考えていたが現在のシンプルな仕様のままがいいと判断した。

== ライセンス
Ruby'sとします。
=end
