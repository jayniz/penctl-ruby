require 'socket'

class Penctl
  
  #
  #  Calls the penctl binary and issues a command. If you set tries_left to something
  #  larger than 0, it will try to contact the pen server again, when it could not
  #  be reached (raising an exception when it gives up).
  #
  def self.execute( server, cmd, tries_left = 5 )
    raise StandardError.new("Error talking to pen, giving up.") unless tries_left > 0
    shell_cmd = "penctl #{server} #{cmd}"
    host, port = server.split ':'
    result = []
    begin
      socket = TCPSocket.open( host, port.to_i )
      socket.puts cmd
      while line = socket.gets
        result << line.chomp
      end
    rescue Errno::ECONNRESET
      sleep 0.5
      return Penctl.execute( server, cmd, tries_left.pred)
    end
    socket.close
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
    tidy_output(Penctl.execute(pen, "#{cmd}#{value}".chomp))
  end
  
  protected
  
  def self.tidy_output( values )
    if values.size == 1
      values[0].match(/^[\d]+$/) ? values[0].to_i : value
    else
      values
    end
  end
end