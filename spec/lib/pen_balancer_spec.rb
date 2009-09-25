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
  
end