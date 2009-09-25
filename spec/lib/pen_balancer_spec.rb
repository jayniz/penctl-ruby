require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'lib/pen_balancer'

describe PenBalancer do

  describe "instance methods" do
    
    before(:each) do
      @pen = PenBalancer.new '127.0.0.1:12000'
    end
    
    it ":servers should return an array of hashes with the servers pen currently knows" do
      servers_reply = ["0 addr 127.0.0.1 port 12101 conn 0 max 0 hard 0 sx 1054463671 rx 2586728338",
                       "1 addr 127.0.0.1 port 12501 conn 1 max 0 hard 0 sx 1103014051 rx 2688785671"]
      @pen.should_receive(:execute_penctl).with("servers").and_return servers_reply
      @pen.should_receive(:parse_server_line).twice.and_return "hash"
      
      result = @pen.servers
      result.should have(2).items
      result[0].should == "hash"
      result[1].should == "hash"
    end
    
    it "should set boolean variables (e.g. http)" do
      @pen.should_receive(:execute_penctl).with('http')
      @pen.http = true
    end
    
    it "should set boolean variables (e.g. no http)" do
      @pen.should_receive(:execute_penctl).with('no http')
      @pen.http = false
    end
    
    it "should set other variables (e.g. debug 5)" do
      @pen.should_receive(:execute_penctl).with('debug 5').and_return ["5"]
      @pen.debug = 5
    end
    
    it "should get other variables (e.g. debug)" do
      @pen.should_receive(:execute_penctl).with('debug').and_return ["5"]
      @pen.debug.should == 5
    end
    
    it "should issue commands (e.g. exit)" do
      @pen.should_receive(:execute_penctl).with('exit').and_return []
      @pen.exit.should be_true
    end
    
    it "should return false when a command could not be issued" do
      @pen.should_receive(:execute_penctl).with('exit').and_return ["Exit is not enabled; restart with -X flag"]
      @pen.exit.should be_false
    end
    
  end
  
  describe "class methods" do
    
    it ":parse_server_line should turn penctl servers output into a hash" do
      line = "1 addr 127.0.0.1 port 12501 conn 2709 max 2212 hard 2 sx 1092895943 rx 2664422154"
      expected = { :slot => 1,
                   :addr => '127.0.0.1',
                   :port => 12501,
                   :conn => 2709,
                   :max  => 2212,
                   :hard => 2,
                   :sx   => 1092895943,
                   :rx   => 2664422154 }
      PenBalancer.parse_server_line(line).should == expected
    end
    
    it ":execute should call the penctl binary and contact the right pen" do
      pen = PenBalancer.new '127.0.0.1:12000'
      IO.should_receive(:popen).with("penctl 127.0.0.1:12000 foo").and_return mock(:readlines => ["something"])
      pen.execute_penctl("foo").should == ["something"]
    end
    
  end
end