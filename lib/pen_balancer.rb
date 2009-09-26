class PenBalancer
  
  BOOLEAN_ATTRIBS = [:ascii=, :block=, :conn_max=, :control=, :control_acl=, :delayed_forward=, :hash=, :http=, :roundrobin=, :stubborn=, :weight=]
  GETTERS_SETTERS = [:blacklist, :client_acl, :control_acl, :debug, :log, :tracking, :timeout, :web_stats]
  GETTERS         = [:clients_max, :conn_max, :control, :listen, :recent, :status]
  COMMANDS        = [:exit!, :include!, :write!]

  #
  #  Creates a new PenBalancer instance: If you have launched a local pen
  #  instance with 8080 as the control port, you should use PenBalancer 
  #  like this: PenBalancer.new 'localhost:8080'
  #
  def initialize( address )
    @pen = address
  end

  #
  #  Returns an array of servers pen currently knows
  #
  def servers
    list = []
    execute_penctl("servers").each do |l| 
      server = parse_server_line(l)
      list[server[:slot]] = server
    end
    list.compact
  end

  #
  #  Takes a line of the output of penctl's 'servers' command and turns it into
  #  a hash with the keys :slot, :addr:, :port, :conn, :max, :hard, :sx, :rx
  #
  def parse_server_line( line )
    keys = %w{ slot addr port conn max hard sx rx}
    hash = Hash[*("slot #{line}".split)]
    server = {}
    keys.each { |k| server[k.to_sym] = (k == "addr") ? hash[k] : hash[k].to_i  }
    return server
  end

  #
  #  Calls the penctl binary and issues a command
  #
  def execute_penctl( cmd )
    cmd = "penctl #{@pen} #{cmd}"
    IO.popen(cmd).readlines.map(&:chomp)
  end
  
  #
  #  penctl has the following three patterns:
  #    1) booleans (no getters): penctl localhost:8080 no ascii
  #                              penctl localhost:8080 ascii
  #    2) getters/setters:       penctl localhost:8080 debug 3
  #                              penctl localhost:8080 debug
  #    3) commands:              penctl localhost:8080 exit
  #  The first two are turned into regular getters and setters and
  #  the last into methods.
  #
  def method_missing(method, *args)
    return set_boolean_attribute(method, args[0])       if BOOLEAN_ATTRIBS.include? method
    return get_set_attribute(method, args[0])           if GETTERS_SETTERS.include? method.to_s.chomp('=').to_sym
    return execute_penctl(method.to_s.chomp('!')) == [] if COMMANDS.include? method
    raise 
  end
  
  def set_boolean_attribute(attribute, value)
    cmd = attribute.to_s.chomp '='
    cmd = value ? cmd : "no " + cmd
    return execute_penctl(cmd) == [0]
  end
  
  def get_set_attribute(attribute, value)
    value ||= 0
    cmd   = attribute.to_s.chomp '='
    value = attribute.to_s['='] ? " #{value}" : ''
    return execute_penctl("#{cmd}#{value}".chomp)[0].to_i # All attributes you can read from penctl are integers
  end
  
  protected 
  
  #
  #  Fetches the list of servers currently known to pen and returns a hash with
  #    :slot, :addr, :port, :conn, :max, :hard, :sx, :rx
  #  Raises an exception when no server with the given address and port is in that list.
  #
  def get_server( addr, port )
    server_list = servers
    server_list.select{ |s| s[:addr] == addr and s[:port] == port} or raise ArgumentError.new("Could not find #{host}:#{port} in #{server_list.inspect}")
  end
  
end
