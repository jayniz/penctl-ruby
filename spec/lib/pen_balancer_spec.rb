require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'lib/pen_balancer'

describe PenBalancer do
  
  describe ":initialize" do
    it "should accept a hash with :host and :port set" do
      lambda{
        PenBalancer.new( :host => '127.0.0.1', :port => '123' )
      }.should_not raise_error
    end
  
    it "should not accept a hash with missing :server" do
      lambda{
        PenBalancer.new( :server => '127.0.0.1' )
      }.should raise_error(ArgumentError)
    end
  end
  
  describe ":servers" do
    
  end
  
  describe "penctl output parsing" do
    
    it "should be able to parse a line" do
      line = "1 addr 127.0.0.1 port 12501 conn 2709 max 2212 hard 2 sx 1092895943 rx 2664422154"
      expected = { :slot => 1,
                   :addr => '127.0.0.1',
                   :port => 12501,
                   :conn => 2709,
                   :max  => 2212,
                   :hard => 2,
                   :sx   => 1092895943,
                   :rx   => 2664422154 }
      PenBalancer.parse_line(line).should == expected
    end
    
  end
end