class PenBalancer
  
  #
  #  Creates a new PenBalancer instance: If you have launched a local pen
  #  instance with 8080 as the control port, you should use PenBalancer 
  #  like this: PenBalancer.new 'localhost:8080'
  #  
  def initialize( address )
    @pen = address
  end

  #
  #  Takes a line of the output of penctl's 'servers' command and turns it into
  #  a hash with the keys :slot, :addr:, :port, :conn, :max, :hard, :sx, :rx
  #
  def self.parse_line( line )
    keys = %w{ slot addr port conn max hard sx rx}
    hash = Hash[*("slot #{line}".split)]
    server = {}
    keys.each { |k| server[k.to_sym] = (k == "addr") ? hash[k] : hash[k].to_i  }
    return server
  end

  def execute( cmd )
    cmd = "penctl #{@pen} #{cmd}"
    IO.popen(cmd).readlines
  end
end
