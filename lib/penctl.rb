class Penctl
  
  #
  #  Calls the penctl binary and issues a command. If you set tries_left to something
  #  larger than 0, it will try to contact the pen server again, when it could not
  #  be reached (raising an exception when it gives up)
  #
  def self.execute( server, cmd, tries_left = -1 )
    raise StandardError.new("Error talking to pen, giving up.") if tries_left == 0
    shell_cmd = "penctl #{server} #{cmd}"
    result = `#{shell_cmd}`.split("\n")
    if tries_left>-0 and $?.to_i!=0
      sleep 0.3
      return Penctl.execute( server, cmd, tries_left.pred) 
    end
    return result
  end

  #
  #  Sends a penctl server command to update a server's settings.
  #
  def self.update_server( server, slot, settings )
    cmd = settings.to_a.sort_by{ |k,v| k.to_s }.flatten.join(' ')
    Penctl.execute( server, "server #{slot} #{cmd}" )
  end


  #
  #  Takes a line of the output of penctl's 'servers' command and turns it into
  #  a hash with the keys :slot, :addr:, :port, :conn, :max, :hard, :sx, :rx
  #
  def self.parse_server_line( line )
    keys = %w{ slot addr port conn max hard sx rx}
    hash = Hash[*("slot #{line}".split)]
    server = {}
    keys.each { |k| server[k.to_sym] = (k == "addr") ? hash[k] : hash[k].to_i  }
    return server
  end


end