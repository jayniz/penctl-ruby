class Penctl
  
  #
  #  Calls the penctl binary and issues a command. If you set tries_left to something
  #  larger than 0, it will try to contact the pen server again, when it could not
  #  be reached (raising an exception when it gives up).
  #
  def self.execute( server, cmd, tries_left = 5 )
    raise StandardError.new("Error talking to pen, giving up.") unless tries_left > 0
    shell_cmd = "penctl #{server} #{cmd}"
#    puts "Executing #{shell_cmd}..."
    result = `#{shell_cmd} 2>&1`.split("\n")    # Redirecting stderr to stdout because of the next line
#    puts "... result is #{result.inspect}"
    if $?.to_i!=0 or result[0]=='error_reading' or (cmd=="servers" and result.empty?)
      sleep 0.3
      return Penctl.execute( server, cmd, tries_left.pred) 
    end
    result
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

  #
  #  Takes an attribute name along with a boolean value and turns it into
  #  a penctl command. Returns true on success, false on failure.
  #
  def self.set_boolean_attribute(pen, attribute, value)
    cmd = attribute.to_s.chomp '='
    cmd = value ? cmd : "no " + cmd
    Penctl.execute(pen, cmd) == ["0"]
  end
  
  #
  #  Takes an attribute name along with a value and returns the value.
  #
  def self.get_set_attribute(pen, attribute, value = nil)
    cmd   = attribute.to_s.chomp '='
    value = value.to_s.empty? ? '' : " #{value}"
    to_int_if_int(Penctl.execute(pen, "#{cmd}#{value}".chomp)[0])
  end
  
  protected
  
  def self.to_int_if_int( value )
    value.match(/^[\d]+$/) ? value.to_i : value
  end
end