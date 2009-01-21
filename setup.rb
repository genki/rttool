#
# setup.rb
#
#   Copyright (c) 2000,2001 Minero Aoki <aamine@loveruby.net>
#
#   This program is free software.
#   You can distribute/modify this program under the terms of
#   the GNU General Public License version 2 or later.
#

require 'tempfile'
if i = ARGV.index(/\A--rbconfig=/) then
  file = $'
  ARGV.delete_at(i)
  require file
else
  require 'rbconfig'
end


class InstallError < StandardError; end


class Installer

  Version   = '2.1.0'
  Copyright = 'Copyright (c) 2000,2001 Minero Aoki'


  TASKS = [
    [ 'config',   'save your config configurations' ],
    [ 'setup',    'compiles extention or else' ],
    [ 'install',  'installs packages' ],
    [ 'clean',    "does `make clean' for each extention" ],
    [ 'dryrun',   'does test run' ],
    [ 'show',     'shows current configuration' ]
  ]

  FILETYPES = %w( bin lib ext share )


  def initialize( root, argv )
    @root_dir  = File.expand_path(root)
    @curr_dir  = ''
    @argv      = argv

    @config    = ConfigTable.create
    @task      = nil
    @task_args = nil
    @verbose   = true
    @hooks     = []

    @no_harm = false  ###tmp
  end

  attr :root_dir
  attr :config
  attr :task
  attr :task_args

  attr :verbose
  attr :no_harm


  def execute
    @task = parsearg( @argv )
    @task_args = @argv
    parsearg_TASK @task, @argv

    @config = ConfigTable.load  unless @task == 'config'
    check_package_configuration unless @task == 'clean'
    load_hooks

    case @task
    when 'config', 'setup', 'install', 'clean'
      tryto @task
    when 'show'
      do_show
    when 'dryrun'
      do_dryrun
    else
      raise 'must not happen'
    end
  end

  def tryto( task )
    $stderr.printf "setup.rb: entering %s phase...\n", task
    begin
      run_hook 'pre', task
      __send__ 'do_' + task
      run_hook 'post', task
    rescue
      $stderr.printf "%s failed\n", task
      raise
    end
    $stderr.printf "setup.rb: %s done.\n", task
  end

  def load_hooks
    install_packages.each do |pack|
      hookfile = "#{@root_dir}/setup/#{pack}.rb"
      if File.exist? hookfile then
        load hookfile
        @hooks.push Object.const_get( "InstallerHook_#{pack}" ).new( self )
      end
    end
  end

  def run_hook( state, task )
    mid = "#{state}_#{task}".intern
    @hooks.each do |hook|
      hook.__send__ mid if hook.respond_to? mid
    end
  end


  ###
  ### processing arguments
  ###

  def parsearg( argv )
    task_re = /\A(?:#{TASKS.collect {|i| i[0] }.join '|'})\z/
    arg = argv.shift

    case arg
    when /\A\w+\z/
      task_re === arg or raise InstallError, "wrong task: #{arg}"
      return arg

    when '-h', '--help'
      print_usage $stdout
      exit 0

    when '-v', '--version'
      puts "setup.rb version #{Version}"
      exit 0
    
    when '--copyright'
      puts Copyright
      exit 0

    else
      raise InstallError, "unknown global option '#{arg}'"
    end
  end


  def parsearg_TASK( task, argv )
    mid = "parsearg_#{task}"
    if respond_to? mid, true then
      __send__ mid, argv
    else
      argv.empty? or
          raise InstallError, "#{task}:  unknown options: #{argv.join ' '}"
    end
  end

  def parsearg_config( args )
    @config_args = {}
    re = /\A--(#{ConfigTable.keys.join '|'})=/
    args.each do |i|
      m = re.match(i) or raise InstallError, "config: unknown option #{i}"
      @config_args[ m[1] ] = m.post_match
    end
  end

  def parsearg_install( args )
    @no_harm = false
    args.each do |i|
      if i == '--no-harm' then
        @no_harm = true
      else
        raise InstallError, "install: unknown option #{i}"
      end
    end
  end

  def parsearg_dryrun( args )
    @dryrun_args = args
  end


  def print_usage( out )
    out.puts
    out.puts 'Usage:'
    out.puts '  ruby setup.rb <global option>'
    out.puts '  ruby setup.rb <task> [<task options>]'

    out.puts
    out.puts 'Tasks:'
    TASKS.each do |name, desc|
      out.printf "  %-10s  %s\n", name, desc
    end

    fmt = "  %-20s %s\n"
    out.puts
    out.puts 'Global options:'
    out.printf fmt, '-h,--help',    'print this message'
    out.printf fmt, '-v,--version', 'print version'
    out.printf fmt, '--copyright',  'print copyright'

    out.puts
    out.puts 'Options for config:'
    ConfigTable::DESCRIPTER.each do |name, (default, arg, desc, default2)|
      default = default2 || default
      out.printf "  %-20s %s [%s]\n", "--#{name}=#{arg}", desc, default
    end
    out.printf "  %-20s %s [%s]\n",
        '--rbconfig=path', 'your rbconfig.rb to load', "running ruby's"

    out.puts
    out.puts 'Options for install:'
    out.printf "  %-20s %s [%s]\n",
        '--no-harm', 'only display what to do if given', 'off'

    out.puts
    out.puts 'This archive includes:'
    out.print '  ', packages().join(' '), "\n"

    out.puts
  end


  ###
  ### tasks
  ###

  def do_config
    @config_args.each do |k,v|
      @config[k] = v
    end
    @config.save
  end

  def do_show
    ConfigTable.each_name do |k|
      v = @config.noproc_get(k)
      if not v or v.empty? then
        v = '(not specified)'
      end
      printf "%-10s %s\n", k, v
    end
  end

  def do_setup
    foreach_package_in( 'bin' ) do
      Dir.foreach( current_directory ) do |fname|
        next unless File.file? "#{current_directory}/#{fname}"
        add_rubypath "#{current_directory}/#{fname}"
      end
    end

    foreach_package_in( 'ext' ) do
      clean
      extconf
      make
    end
  end

  def do_install
    foreach_package_in( 'bin' ) do |targ, *dummy|
      install_bin
    end

    foreach_package_in( 'lib' ) do |targ, topfile|
      install_rb targ
      if topfile then
        create_topfile targ, topfile
      end
    end

    foreach_package_in( 'ext' ) do |targ, *dummy|
      install_so targ
    end

    foreach_package_in( 'share' ) do |targ, *dummy|
      install_dat targ
    end
  end

  def do_clean
    Dir.glob( 'ext/*' ).each do |name|
      if dir? name then
        chdir( name ) {
          clean
        }
      end
    end
    rmf ConfigTable::SAVE_FILE
  end
  
  def do_dryrun
    unless dir? 'tmp' then
      $stderr.puts 'setup.rb: setting up temporaly environment...'
      @verbose = $DEBUG
      begin
        @config['bin-dir']  = isdir(File.expand_path('.'), 'tmp', 'bin')
        @config['rb-dir']   = isdir(File.expand_path('.'), 'tmp', 'lib')
        @config['so-dir']   = isdir(File.expand_path('.'), 'tmp', 'ext')
        @config['data-dir'] = isdir(File.expand_path('.'), 'tmp', 'share')
        do_install
      rescue
        rmrf 'tmp'
        $stderr.puts '[BUG] setup.rb: cannot prepare tmp/ for dryrun'
        raise
      end
    end

    exec @config['ruby-prog'], '-I./tmp/lib', '-I./tmp/ext', * @dryrun_args
  end
  

  ###
  ### lib
  ###

  #
  # config
  #

  class ConfigTable

    c = ::Config::CONFIG

    rubypath = c['bindir'] + '/' + c['ruby_install_name']

    major = c['MAJOR'].to_i
    minor = c['MINOR'].to_i
    teeny = c['TEENY'].to_i
    version = "#{major}.#{minor}"

    # >=1.4.4 is new path
    newpath_p = ((major >= 2) or
                 ((major == 1) and
                  ((minor >= 5) or
                   ((minor == 4) and (teeny >= 4)))))
    
    if newpath_p then
      sitelibdir = "site_ruby/#{version}"
    else
      sitelibdir = "#{version}/site_ruby"
    end

    DESCRIPTER = [
      [ 'prefix',    [ c['prefix'],
                       'path',
                       'path prefix' ] ],
      [ 'std-ruby',  [ "$prefix/lib/ruby/#{version}",
                       'path',
                       'directory for standard ruby libraries' ] ],
      [ 'site-ruby', [ "$prefix/lib/ruby/#{sitelibdir}",
                       'path',
                       'directory for non-standard ruby libraries' ] ],
      [ 'bin-dir',   [ '$prefix/bin',
                       'path',
                       'directory to install commands' ] ],
      [ 'rb-dir',    [ '$site-ruby',
                       'path',
                       'directory to install ruby scripts' ] ],
      [ 'so-dir',    [ "$site-ruby/#{c['arch']}",
                       'path',
                       'directory to install ruby extentions' ] ],
      [ 'data-dir',  [ '$prefix/share',
                       'path',
                       'directory to install data' ] ],
      [ 'ruby-path', [ rubypath,
                       'path',
                       'path to ruby for #!' ] ],
      [ 'ruby-prog', [ rubypath,
                       'path',
                       'path to ruby for installation' ] ],
      [ 'make-prog', [ 'make',
                       'name',
                       'make program to compile ruby extentions' ] ],
      [ 'with',      [ '',
                       'name,name...',
                       'package name(s) you want to install' ],
                       'ALL' ],
      [ 'without',   [ '',
                       'name,name...',
                       'package name(s) you do not want to install' ] ]
    ]

    def self.each_name( &block )
      keys().each( &block )
    end

    def self.keys
      DESCRIPTER.collect {|k,*discard| k }
    end


    SAVE_FILE = 'config.save'

    def self.create
      c = new()
      c.init
      c
    end

    def self.load
      c = new()
      File.file? SAVE_FILE or raise InstallError, 'setup.rb config first'
      File.foreach( SAVE_FILE ) do |line|
        k, v = line.split( '=', 2 )
        c.noproc_set k, v.strip
      end
      c
    end

    def initialize
      @table = {}
    end

    def init
      DESCRIPTER.each do |k, (default, vname, desc, default2)|
        @table[k] = default
      end
    end

    def save
      File.open( SAVE_FILE, 'w' ) do |f|
        @table.each do |k, v|
          f.printf "%s=%s\n", k, v if v
        end
      end
    end

    def []=( k, v )
      if DESCRIPTER.assoc(k)[1][1] == 'path' then
        @table[k] = File.expand_path(v)
      else
        @table[k] = v
      end
    end
      
    def []( key )
      r = (   @table[key] and @table[key].sub( %r_\$([^/]+)_ ) { self[$1] }  )
      r
    end

    def noproc_set( key, val )
      @table[key] = val
    end

    def noproc_get( key )
      @table[key]
    end

  end


  #
  # packages
  #

  def check_package_configuration
    @with    = extract_dirs( @config['with'] )
    @without = extract_dirs( @config['without'] )

    packs = packages()
    (@with + @without).each do |i|
      if not packs.include? i and not dir? i then
        raise InstallError, "no such package or directory '#{i}'"
      end
    end
  end

  def extract_dirs( s )
    ret = []
    s.split(',').each do |i|
      if /[\*\?]/ === i then
        tmp = Dir.glob(i)
        tmp.delete_if {|d| not dir? d }
        if tmp.empty? then
          tmp.push i   # causes error
        else
          ret.concat tmp
        end
      else
        ret.push i
      end
    end

    ret
  end

  def packages
    ret = []
    FILETYPES.each do |type|
      next unless File.directory? subpath(type)
      foreach_record( subpath(type, 'PATHCONV') ) do |dir, pack, *dummy|
        ret.push pack
      end
    end
    ret.uniq
  end

  def install_packages
    ret = []
    FILETYPES.each do |type|
      next unless File.directory? subpath(type)
      foreach_record( subpath(type, 'PATHCONV') ) do |dir, pack, *dummy|
        ret.push pack if install_package? pack, "#{type}/#{dir}"
      end
    end
    ret.uniq
  end

  def install_package?( pack, dir )
    if @with.empty? then
      not @without.include? pack and
      not @without.include? dir
    else
      @with.include? pack or
      @with.include? dir
    end
  end

  def foreach_record( fname )
    File.foreach( fname ) do |line|
      line.strip!
      next if line.empty?
      a = line.split(/\s+/)
      a[2] ||= '.'
      yield a
    end
  end

  def foreach_package_in( filetype )
    return unless dir? subpath(filetype)

    descripter = {}
    foreach_record( subpath(filetype, 'PATHCONV') ) do |dir, pack, targ, topfile, *dummy|
      descripter[dir] = [pack, targ, topfile]
    end

    Dir.foreach( subpath(filetype) ) do |dir|
      next if dir == 'CVS'
      next if dir[0] == ?.
      next unless dir? subpath(filetype, dir)

      descripter[dir] or raise "abs path for package '#{dir}' not exist"
      pack, targ, topfile = descripter[dir]

      relpath = "#{filetype}/#{dir}"
      if install_package? pack, relpath then
        mkpath relpath
        chdir( relpath ) {
          @curr_dir = relpath
          yield targ, topfile
        }
        @curr_dir = ''
      else
        $stderr.puts "setup.rb: skip #{relpath}(#{pack}) by user option"
      end
    end
  end


  #
  # setup
  #

  def add_rubypath( path )
    $stderr.puts %Q<setting #! line to "\#!#{@config['ruby-path']}"> if @verbose
    return if @no_harm

    tmpf = nil
    File.open( path ) do |f|
      first = f.gets
      return unless /\A\#!\S*ruby/ === first   # reject '/usr/bin/env ruby'

      tmpf = Tempfile.open( 'amsetup' )
      tmpf.print first.sub( /\A\#!\s*\S+/, '#!' + @config['ruby-path'] )
      tmpf.write f.read
      tmpf.close
    end
    
    mod = File.stat( path ).mode
    tmpf.open
    File.open( File.basename(path), 'w' ) {|w|
      w.write tmpf.read
    }
    File.chmod mod, File.basename(path)

    tmpf.close true
  end


  #
  # install
  #

  def install_bin
    install_all isdir(@config['bin-dir']), 0555
  end

  def install_rb( dir )
    install_all isdir(@config['rb-dir'] + '/' + dir), 0644
  end

  def install_dat( dir )
    install_all isdir(@config['data-dir'] + '/' + dir), 0644
  end

  def install_all( dest, mode )
    Dir.foreach( current_directory ) do |fname|
      next if fname[0,1] == '.'
      next unless File.file? "#{current_directory}/#{fname}"
      unless File.file? fname then
        fname = "#{current_directory}/#{fname}"
      end

      install fname, dest, mode
    end
  end

  def create_topfile( name, req )
    d = isdir(@config['rb-dir'])
    $stderr.puts "creating wrapper file #{d}/#{name}.rb ..." if @verbose
    return if @no_harm

    File.open( "#{d}/#{name}.rb", 'w' ) do |f|
      f.puts "require '#{name}/#{req}'"
    end
    File.chmod 0644, "#{d}/#{name}.rb"
  end


  def extconf
    command "#{@config['ruby-prog']} #{current_directory}/extconf.rb"
  end

  def make
    command @config['make-prog']
  end
  
  def clean
    command @config['make-prog'] + ' clean' if File.file? 'Makefile'
  end

  def install_so( dest )
    to = isdir(File.expand_path(@config['so-dir']) + '/' + dest)
    find_so('.').each do |name|
      install name, to, 0555
    end
  end

  DLEXT = ::Config::CONFIG['DLEXT']

  def find_so( dir )
    fnames = nil
    Dir.open( dir ) {|d| fnames = d.to_a }
    exp = /\.#{DLEXT}\z/
    fnames.find_all {|fn| exp === fn } or
          raise InstallError,
          'no ruby extention exists: have you done "ruby setup.rb setup" ?'
  end

  def so_dir?( dir = '.' )
    File.file? "#{dir}/MANIFEST"
  end


  #
  # file operations
  #

  def subpath( *pathes )
    File.join( @root_dir, *pathes )
  end

  def current_directory
    "#{@root_dir}/#{@curr_dir}"
  end

  def isdir( dn )
    mkpath dn
    dn
  end

  def chdir( path )
    save = Dir.pwd
    Dir.chdir path
    yield
    Dir.chdir save
  end

  def mkpath( dname )
    $stderr.puts "mkdir -p #{dname}" if @verbose
    return if @no_harm

    # does not check '/'... it's too abnormal case
    dirs = dname.split(%r_(?=/)_)
    if /\A[a-z]:\z/i === dirs[0] then
      disk = dirs.shift
      dirs[0] = disk + dirs[0]
    end
    dirs.each_index do |idx|
      path = dirs[0..idx].join('')
      Dir.mkdir path unless dir? path
    end
  end

  def rmf( fname )
    $stderr.puts "rm -f #{fname}" if @verbose
    return if @no_harm

    if File.exist? fname or File.symlink? fname then
      File.chmod 777, fname
      File.unlink fname
    end
  end

  def rmrf( dn )
    $stderr.puts "rm -rf #{dn}" if @verbose
    return if @no_harm

    Dir.chdir dn
    Dir.foreach('.') do |fn|
      next if fn == '.'
      next if fn == '..'
      if dir? fn then
        verbose_off {
          rmrf fn
        }
      else
        verbose_off {
          rmf fn
        }
      end
    end
    Dir.chdir '..'
    Dir.rmdir dn
  end

  def verbose_off
    save, @verbose = @verbose, false
    yield
    @verbose = save
  end

  def install( from, to, mode )
    $stderr.puts "install #{from} #{to}" if @verbose
    return if @no_harm

    if dir? to then
      to = to + '/' + File.basename(from)
    end
    str = nil
    File.open( from, 'rb' ) {|f| str = f.read }
    if diff? str, to then
      verbose_off {
        rmf to if File.exist? to
      }
      File.open( to, 'wb' ) {|f| f.write str }
      File.chmod mode, to
    end
  end

  def diff?( orig, comp )
    return true unless File.exist? comp
    s2 = nil
    File.open( comp, 'rb' ) {|f| s2 = f.read }
    orig != s2
  end

  def command( str )
    $stderr.puts str if @verbose
    system str or raise RuntimeError, "'system #{str}' failed"
  end

  def dir?( dname )
    # for corrupted windows stat()
    File.directory?( (dname[-1,1] == '/') ? dname : dname + '/' )
  end

end


class InstallerHook

  def initialize( i )
    @installer = i
  end

  attr :installer

  def package_root
    @installer.root_dir
  end

end


if $0 == __FILE__ then
  begin
    installer = Installer.new( File.dirname($0), ARGV.dup )
    installer.execute
  rescue => err
    raise if $DEBUG
    $stderr.puts err.message
    $stderr.puts 'try "ruby setup.rb --help" for usage'
    exit 1
  end
end
