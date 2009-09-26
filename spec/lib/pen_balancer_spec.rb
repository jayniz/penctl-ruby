require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'lib/pen_balancer'

describe PenBalancer do

  describe "methods implementing the commands from `man penctl` (except for acl and server)" do
    
    before(:each) do
      @pen = PenBalancer.new '127.0.0.1:12000'
    end
    
    it ":servers should return an array of hashes with the servers pen currently knows" do
      servers_reply = ["0 addr 127.0.0.1 port 12101 conn 0 max 0 hard 0 sx 1054463671 rx 2586728338",
                       "1 addr 127.0.0.1 port 12501 conn 1 max 0 hard 0 sx 1103014051 rx 2688785671"]
      @pen.should_receive(:execute_penctl).with("servers").and_return servers_reply

      result = @pen.servers
      result.should have(2).items
      result[0].should be_a(Hash)
      result[1].should be_a(Hash)
    end
    
    it "should set boolean variables (e.g. pen.http=true)" do
      @pen.should_receive(:execute_penctl).with('http')
      @pen.http = true
    end
    
    it "should set boolean variables (e.g. pen.http=false)" do
      @pen.should_receive(:execute_penctl).with('no http')
      @pen.http = false
    end
    
    it "should set other variables (e.g. pen.debug=5)" do
      @pen.should_receive(:execute_penctl).with('debug 5').and_return ["5"]
      @pen.debug = 5
    end
    
    it "should get other variables (e.g. pen.debug)" do
      @pen.should_receive(:execute_penctl).with('debug').and_return ["5"]
      @pen.debug.should == 5
    end
    
    it "should issue commands (e.g. pen.exit!)" do
      @pen.should_receive(:execute_penctl).with('exit').and_return []
      @pen.exit!.should be_true
    end
    
    it "should return false when a command could not be issued" do
      @pen.should_receive(:execute_penctl).with('exit').and_return ["Exit is not enabled; restart with -X flag"]
      @pen.exit!.should be_false
    end
    
  end

  describe "methods making the penctl commands [no] acl and server more convenient" do
    
    describe "adding or removing servers to the pool" do
      
      before(:each) do
        @pen = PenBalancer.new '127.0.0.1:12000'
        servers_reply = ["0 addr 127.0.0.1 port 100 conn 0 max 0 hard 0 sx 1054463671 rx 2586728338",
                         "1 addr 127.0.0.1 port 101 conn 1 max 0 hard 0 sx 1103014051 rx 2688785671",
                         "2 addr 0.0.0.0 port 0 conn 0 max 0 hard 0 sx 0 rx 0"]
        @pen.should_receive(:execute_penctl).with("servers").and_return servers_reply
      end
      
      xit "should add a server into an empty slot" do
        @pen.add_server('127.0.0.1', 102).should be_true
      end
      
      xit "should remove a server freeing a slot" do
        @pen.remove_server('127.0.0.1', 102).should be_true
      end
      
      it "should raise an exception when given server could not be found in the list"
      it "should raise an exception when adding a server and slots are full"
      it "should raise an exception when adding a server that is already in the list"
      
    end
    
    describe "managing access control" do
      it "should set access control list"
      it "should remove access control (allow from all)"
      it "should raise an exception when given ACL list is out of range [0..9]"
    end
  end
  
  describe "utility methods to talk to pen via penctl" do
    
    before(:each) do
      @pen = PenBalancer.new '127.0.0.1:12000'
    end
    
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
      @pen.parse_server_line(line).should == expected
    end
    
    it ":execute should call the penctl binary and contact the right pen" do
      IO.should_receive(:popen).with("penctl 127.0.0.1:12000 foo").and_return mock(:readlines => ["something"])
      @pen.execute_penctl("foo").should == ["something"]
    end
    
  end

end