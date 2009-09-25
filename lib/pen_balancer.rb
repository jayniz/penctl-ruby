class PenBalancer
  
  def initialize( options )
    unknown_keys = options.keys - [:host, :port].flatten
    raise(ArgumentError, "Unknown key(s): #{unknown_keys.join(", ")}") unless unknown_keys.empty?
  end
  
  protected
  
  def self.parse_line( line )
    keys = %w{ slot addr port conn max hard sx rx}
    hash = Hash[*("slot #{line}".split)]
    server = {}
    keys.each { |k| server[k.to_sym] = (k == "addr") ? hash[k] : hash[k].to_i  }
    return server
  end
  
end

__END__
line = "1 addr 127.0.0.1 port 12501 conn 2709 max 2212 hard 0 sx 1092895943 rx 2664422154"