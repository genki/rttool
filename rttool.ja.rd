=begin


= RTtool

##### [whats new]
== ��������
=== [2006/09/20] 1.0.2 released
*  ���ԥ����ɤ�DOS, MAC���Ȥ��ޤ�ư��ʤ��Х�������

=== [2005/10/28] 1.0.1 released
*  .rd2rc��Ȥ�ʤ��ʤä���
=== [2005/10/26] 1.0.0 released
*  ���������פǤ���褦�ˤʤä����Ѹ�Υɥ��������°��
*  Ruby1.8��warning������
  
=== [2001/11/15] 0.1.7 released
*  ���Ĥ��ο����Ǥⱦ·���ˤ���褦�ˤ�����
=== [2001/08/07] 0.1.6 released
*  ���򥻥�ν����ǤΥХ����н衣
=== [2001/07/17] 0.1.5 released
*  rt2html-lib.rb: caption�����ꤷ�Ƥʤ��Ȥ���CAPTION���Ǥ�Ĥ��ʤ��褦�ˡ�
=== [2001/07/09] 0.1.4 released
*  �����������setup.rb����ѡ� �����ȼ�����ѥå������������ѹ���
=== [2001/06/03] 0.1.3 released
*  rt2html-lib.rb�ˤ����ƥ�����ʸ�����ѹ��������XHTML�Ǥ�����ס�
  
##### [/whats new]

##### [abstract]
== ����

RTtool�ϥ���ץ�ʺ�ɽ�ġ��롣
RD�����Ǥ���((*������*))��((*���ޤ��ޤʥե����ޥåȤ��Ѵ���ǽ*))��Ѿ�����
RDtool�μ¸�Ū��ǽ�ǤϤ��뤬filter��ǽ�ˤ��RD��((*ͻ��*))�����뤳�Ȥ���ǽ�Ǥ��롣
���äƤߤ��((*����ߤ����ʤ�ΤǤ��롣*))

���ΤȤ���RT��HTML��Plain text����((<w3m|URL:http://w3m.sourceforge.net/>))�ˤ��Ѵ��Ǥ��롣
w3m��Windows�Ǥ�Cygwin�����ʤ��Τǡ�Windows�οͤ�Cygwin��Ȥ�ɬ�פ����롣
HTML�ؤ��Ѵ��Τ�ɬ�פʤ��w3m�����פǤ��롣

�߷פ�����RDtool�Ȼ����Ƥ��롣
parser��visitor��ʬ����rt2html-lib.rb�������

##### [/abstract]


##### [install]
== ���󥹥ȡ���
�ʲ��Υ��ޥ�ɤ�¹ԡ�

    ruby -ropen-uri -e 'URI("http://www.rubyist.net/~rubikitch/archive/rttool-1.0.2.tar.gz").read.display' > rttool-1.0.2.tar.gz
  tar xzvf rttool-1.0.2.tar.gz


���Ԥ�����ϼ��Υ�󥯤����������ɡ�

* ((<rttool-1.0.2.tar.gz|URL:http://www.rubyist.net/~rubikitch/archive/rttool-1.0.2.tar.gz>))

���줫�鼡�Υ��ޥ�ɤǥ��󥹥ȡ��롣

  cd rttool-1.0.2
  ruby setup.rb config
  ruby setup.rb setup
  ruby setup.rb install


##### [/install]

(1)�ѥå������ˤ��� rt �ǥ��쥯�ȥ�� $LOAD_PATH ���̤ä��ǥ��쥯�ȥ�˥��ԡ����롣
   * (({require 'rt/rtparse'}))�ȻȤ���Τǡ�
(2)rt/rt2 ���ޥ�ɤ� PATH ���̤ä��ǥ��쥯�ȥ�˰�ư���롣
(3)rt/dot.rt.rd2rc
   * �⤷ ~/.rd2rc �Ȥ����ե����뤬¸�ߤ��ʤ���С� ~/.rd2rc �˥�͡��ࡣ
   * ¸�ߤ���Ȥ��ϡ���ʬ��Ŭ�����ꤹ�롣
== RT��ʸˡ
* RT��3�Ĥ�Block�ǹ��������
  :ConfigBlock
    ��°�� = �͡פ��Ȥ���ʤ롣
    �ʲ�����Ǥ� caption °�������ꤷ��ɽ���Ĥ��Ƥ��롣
    ����Block�Ͼ�ά�Ǥ��롣
  :HeaderBlock
    HTML�Ǥ���THEAD����ʬ��
    ɽ�Υإå������ꤹ�롣
    �إå������·���ˤʤ롣
    ����Block���ά�Ǥ��롣
  :BodyBlock
    HTML�Ǥ���TBODY����ʬ��
    �ǡ����򵭽Ҥ��롣
    �����ϱ�·��������ʳ��Ϻ�·���ˤʤ롣
* HeaderBlock, BodyBlock �ι��ܤζ��ڤ� ((',')) ��Tab�Ǥ��롣
  * ɬ�������ιԤ�·�äƤ���ɬ�פϤʤ���
    ������·�����������䤹���ȤϤ����롣
  * ����ʸ���� delimiter °�����ͤ��Ѥ��뤳�Ȥ�Ǥ�դ�ʸ����ˤǤ��롣
* (('=='))�Ϻ�����򿭤Ф���
  HTML�Ǥ���TH��TD���Ǥ�colspan°���˱ƶ���
  * rowspan °�����ͤ��Ѥ��뤳�Ȥ�Ǥ�դ�ʸ����ˤǤ��롣
* (('||'))�Ͼ�ιԤ򿭤Ф���
  HTML�Ǥ���TH��TD���Ǥ�rowspan°���˱ƶ���
  * colspan °�����ͤ��Ѥ��뤳�Ȥ�Ǥ�դ�ʸ���ˤǤ��롣

== °������
ConfigBlock�Ǥϼ���°��������Ǥ��롣

:caption
  ɽ�Υ����ȥ�����ꤹ�롣

:delimiter
  �ǡ����ζ��ڤ���ꤹ�롣

:rowspan
  ������򿭤Ф����ꡣ�ʥǥե���Ȥ�(({==}))��

:colspan
  ��ιԤ򿭤Ф����ꡣ�ʥǥե���Ȥ�(({||}))��
  
:escape
  delimiter��ǡ����˴ޤ��ɬ�פ�����Ȥ��ˤ���°���ǻ��ꤵ�줿ʸ�������֤��롣
  �ǥե���ȤǤ�̵���ȤʤäƤ��롣
== ��

=== ���ִ�ñ��RT
�ͤ򥫥�ޤǶ��ڤ�Τ����ִ�ñ��RT��

  $ cat examples/easiest.rt
  1, 2, 3
  4, 5, 6
  7, 8, 9

  $ rt2 examples/easiest.rt
  ��������������
  �� 1�� 2�� 3��
  ��������������
  �� 4�� 5�� 6��
  ��������������
  �� 7�� 8�� 9��
  ��������������

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
  



=== ����������
RT��delimiter��ͳ�˻���Ǥ��뤬��delimiter���Ϥ�ʸ�˴ޤ��ɬ�פ�����Ȥ���
* delimiter���̤ʤ�Τ��ִ����뤫
* 1.0.0��Ƴ�����줿���������פ�Ȥ�

���������פϡ�delimiterʸ���������֤����Ȥǡ�delimiter�ǤϤʤ����Ϥ�ʸ�Ȥߤʤ���롣

  $ cat examples/escape.rt
  delimiter = ;
  escape = \
  
  \z   ; \;1 ; 2

  $ rt2 examples/escape.rt
  ��������������
  ��\z��;1�� 2��
  ��������������

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
  



=== ����ä�ʣ����RT

  $ cat examples/test1.rt
  caption = Test Table
  
       , Human, == , Dog , ==
  ||  , M  , F ,M,F
  
    x  , 1.0 , 2.0, 1.1, 1.2
    y  , 0.4 , 0.5, 0.3, 0.1

  $ rt2 examples/test1.rt
            Test Table
  ������������������������������
  ��  ��  Human   ��   Dog    ��
  ��  ��������������������������
  ��  �� M  �� F  �� M  �� F  ��
  ������������������������������
  ��x �� 1.0�� 2.0�� 1.1�� 1.2��
  ������������������������������
  ��y �� 0.4�� 0.5�� 0.3�� 0.1��
  ������������������������������

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
  



=== RD��������
����ˡ�RD�������ळ�Ȥ�Ǥ���Τ���
RT��((*RD�ǤϤʤ��Τ�RD��filter��ǽ��Ȥ�*))���Ȥˤʤ롣
�����ɽ�Ĥ��Υƥ����Ȥ������Ǥ��롣
begin��end���ѻ��ʤΤ�RDtool�λ��ͤʤΤǤ��礦���ʤ���
���ޥ�ɥ饤��Ĺ���ʤ�Τ�rdrt2�Ȥ������ޥ�ɤ��Ѱա�

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
  ������������������������������
  ��  ��  Human   ��   Dog    ��
  ��  ��������������������������
  ��  �� M  �� F  �� M  �� F  ��
  ������������������������������
  ��x �� 1.0�� 2.0�� 1.1�� 1.2��
  ������������������������������
  ��y �� 0.4�� 0.5�� 0.3�� 0.1��
  ������������������������������
  
  It is simple.
  



== �ʤ���RT
* HTML��LaTeX��ɽ�ν��������礤����Ĥ���
  * �ɤ߽񤭤��ˤ�����
* RD��ɽ������ǽ������Ф���������������������
  * RD��ʸˡ��ʣ���ˤʤ롣
  * RD�Ȥ��Ƹ��ɤ��ʤ롣
* RT����ʬ�����ȼ����ѹ�����ǽ��
* ����RD�򰦤��Ƥ뤫�顣
* ��ʬ�˹�ä�ɽ�����ġ��뤬�ۤ�����

== TODO
��6ǯ��������ʤ��Ȥ�ͤ��Ƥ��������ߤΥ���ץ�ʻ��ͤΤޤޤ�������Ƚ�Ǥ�����

== �饤����
Ruby's�Ȥ��ޤ���
=end
