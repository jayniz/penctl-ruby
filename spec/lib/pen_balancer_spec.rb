require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'lib/pen_balancer'

describe PenBalancer do

  describe "instance methods" do
    it "" do
      
    end
  end
  
  describe "class methods" do
    
    it ":parse_line should turn penctl servers output into a hash" do
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
    
    it ":execute should call the penctl binary and contact the right pen" do
      pen = PenBalancer.new '127.0.0.1:12000'
      IO.should_receive(:popen).with("penctl 127.0.0.1:12000 foo").and_return mock(:readlines => ["something"])
      pen.execute("foo").should == ["something"]
    end
    
  end
end