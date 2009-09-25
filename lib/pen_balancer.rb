class PenBalancer
  
  def initialize( options )
    unknown_keys = options.keys - [:host, :port].flatten
    raise(ArgumentError, "Unknown key(s): #{unknown_keys.join(", ")}") unless unknown_keys.empty?
  end
  
  def servers
    
  end
  
end