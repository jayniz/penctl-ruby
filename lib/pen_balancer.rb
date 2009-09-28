require 'lib/penctl'

class PenBalancer
  
  # TODO: :log       has log, log=false and log=file
  
  BOOLEAN_ATTRIBS = [:ascii=, :block=, :conn_max=, :control=, :delayed_forward=, :hash=, :http=, :roundrobin=, :stubborn=, :weight=]
  GETTERS_SETTERS = [:blacklist, :client_acl, :control_acl, :debug, :log, :tracking, :timeout, :web_stats]
  GETTERS         = [:clients_max, :conn_max, :control, :listen, :status, :recent]
  COMMANDS        = [:exit!, :include!, :write!, :file!]

  #
  #  Creates a new PenBalancer instance: If you have launched a local pen
  #  instance with 8080 as the control port, you should use PenBalancer 
  #  like this: PenBalancer.new 'localhost:8080'.
  #  
  #  Throws an exception when pen can't be reached.
  #
  def initialize( address )
    @pen = address
    raise "Can't find pen balancer at #{address}" unless Penctl.execute( @pen, "control")[0].match /#{address.split(':')[1]}/
  end

  #
  #  Returns an array of servers pen currently knows
  #
  def servers
    list = []
    Penctl.execute(@pen, "servers", 5).each do |l| 
      server = Penctl.parse_server_line(l)
      list[server[:slot]] = server
    end
    list.compact
  end

  #
  #  Adds a server to the pool or throws an exception when there is no free
  #  slot left
  #
  def add_server( host, port )
    raise ArgumentError.new("Server is in the pool already") if server_in_pool?( host, port)
    free_slot = get_server( '0.0.0.0', 0 )
    Penctl.update_server( @pen, free_slot[:slot], :address => host, :port => port)
    server_in_pool? host, port
  end
  
  #
  #  Removes a server from the pool or throws an exception when the server
  #  cannot be found in the pool
  #
  def remove_server( host, port )
    server = get_server( host, port )
    Penctl.update_server( @pen, server[:slot], :address => '0.0.0.0', :port => 0 )
    !server_in_pool? host, port
  end
  
  #
  #  Updates an entry of the access control list. Params is a hash with
  #  mandatory :policy => permit/deny and :source_ip. You can optionally
  #  pass a :netmask.
  #
  def set_acl_entry( slot, params )
    raise RangeError.new("slot #{slot} outside range 0-9")       unless (0..9).include?(slot)
    raise ArgumentError.new("policy must be either permit or deny") unless ['permit', 'deny'].include? params[:policy]
    Penctl.execute(@pen, "acl #{slot} #{params[:policy]} #{params[:source_ip]} #{params[:netmask]}".strip)
  end
  
  #
  #  Flushes the rules of an acl entry (==permit from all)
  #
  def remove_acl_entry( slot )
    raise RangeError.new("slot #{slot} outside range 0-9") unless (0..9).include?(slot)
    Penctl.execute(@pen, "no acl #{slot}")
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
    return Penctl.set_boolean_attribute(@pen, method, args[0])                if BOOLEAN_ATTRIBS.include? method
    return Penctl.get_set_attribute(@pen, method, args[0])                    if GETTERS_SETTERS.include? method.to_s.chomp('=').to_sym
    return Penctl.get_set_attribute(@pen, method, args[0])                    if GETTERS.include? method
    return Penctl.execute(@pen, "#{method.to_s.chomp('!')} #{args[0]}".strip) if COMMANDS.include? method
    raise "Missing method #{method}"
  end
  
  protected 
  
  #
  #  Fetches the list of servers currently known to pen and returns a hash with
  #    :slot, :addr, :port, :conn, :max, :hard, :sx, :rx
  #  Raises an exception when no server with the given address and port is in that list.
  #
  def get_server( host, port )
    server_list = servers
    server_list.select{ |s| s[:addr] == host and s[:port] == port.to_i}[0] or raise ArgumentError.new("Could not find #{host}:#{port} in #{server_list.inspect}")
  end
  
  #
  #  Checks if a given server is already in the pool
  #
  def server_in_pool?( host, port )
    server_list = servers
    !server_list.select{ |s| s[:addr] == host and s[:port] == port.to_i}.empty?
  end
end
