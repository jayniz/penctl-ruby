require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'lib/pen_balancer'
require 'lib/penctl'

describe PenBalancer do

  describe "methods implementing the commands from `man penctl` (except for acl and server)" do
    
    before(:each) do
      Penctl.should_receive(:execute).with("127.0.0.1:12000", "control").and_return ["127.0.0.1:12000"]
      @pen = PenBalancer.new '127.0.0.1:12000'
    end
    
    it ":servers should return an array of hashes with the servers pen currently knows" do
      servers_reply = ["0 addr 127.0.0.1 port 12101 conn 0 max 0 hard 0 sx 1054463671 rx 2586728338",
                       "1 addr 127.0.0.1 port 12501 conn 1 max 0 hard 0 sx 1103014051 rx 2688785671"]
      Penctl.should_receive(:execute).with("127.0.0.1:12000", "servers", 5).and_return servers_reply

      result = @pen.servers
      result.should have(2).items
      result[0].should be_a(Hash)
      result[1].should be_a(Hash)
    end
    
    it "should set boolean variables (e.g. pen.http=true)" do
      Penctl.should_receive(:execute).with("127.0.0.1:12000", 'http')
      @pen.http = true
    end
    
    it "should set boolean variables (e.g. pen.http=false)" do
      Penctl.should_receive(:execute).with("127.0.0.1:12000", 'no http')
      @pen.http = false
    end
    
    it "should set other variables (e.g. pen.debug=5)" do
      Penctl.should_receive(:execute).with("127.0.0.1:12000", 'debug 5').and_return ["5"]
      @pen.debug = 5
    end
    
    it "should get other variables (e.g. pen.debug)" do
      Penctl.should_receive(:execute).with("127.0.0.1:12000", 'debug').and_return ["5"]
      @pen.debug.should == 5
    end
    
    it "should get readonly variables (e.g. pen.status)" do
      Penctl.should_receive(:execute).with("127.0.0.1:12000", 'status').and_return ["lots", "of", "lines"]
      @pen.status.should == ["lots", "of", "lines"]
    end
    
    it "should get readonly variables with a parameter (e.g. pen.recent(5))" do
      Penctl.should_receive(:execute).with("127.0.0.1:12000", 'recent 5').and_return ["lots", "of", "lines"]
      @pen.recent(5).should == ["lots", "of", "lines"]
    end
    
    it "should issue commands (e.g. pen.exit!)" do
      Penctl.should_receive(:execute).with("127.0.0.1:12000", 'exit').and_return []
      @pen.exit!
    end
    
    it "should issue commands with parameters (e.g. pen.file! /etc/pen.conf)" do
      Penctl.should_receive(:execute).with("127.0.0.1:12000", 'file /etc/pen.conf').and_return []
      @pen.file!('/etc/pen.conf').should be_true
    end
    
    it "should return false when a command could not be issued" do
      Penctl.should_receive(:execute).with("127.0.0.1:12000", 'exit').and_return ["Exit is not enabled; restart with -X flag"]
      @pen.exit!
    end
    
  end

  describe "methods making the penctl commands [no] acl and server more convenient" do
    
    describe "adding or removing servers from the pool" do
      
      before(:each) do
        Penctl.should_receive(:execute).with("127.0.0.1:12000", "control").and_return ["127.0.0.1:12000"]
        @pen = PenBalancer.new '127.0.0.1:12000'
        servers_reply = ["0 addr 127.0.0.1 port 100 conn 0 max 0 hard 0 sx 1054463671 rx 2586728338",
                         "1 addr 127.0.0.1 port 101 conn 1 max 0 hard 0 sx 1103014051 rx 2688785671",
                         "2 addr 0.0.0.0 port 0 conn 0 max 0 hard 0 sx 0 rx 0",
                         "3 addr 0.0.0.0 port 0 conn 0 max 0 hard 0 sx 0 rx 0"]
        Penctl.should_receive(:execute).with("127.0.0.1:12000", "servers", 5).at_least(1).and_return servers_reply
      end
      
      it "should add a server into an empty slot" do
        Penctl.should_receive(:update_server).with('127.0.0.1:12000', 2, :address => '127.0.0.1', :port => 102)
        @pen.should_receive(:server_in_pool?).with('127.0.0.1', 102).and_return false
        @pen.should_receive(:server_in_pool?).with('127.0.0.1', 102).and_return true
        @pen.add_server('127.0.0.1', 102).should be_true
      end
      
      it "should remove a server freeing a slot" do
        Penctl.should_receive(:update_server).with('127.0.0.1:12000', 1, :address => '0.0.0.0', :port => 0)
        @pen.should_receive(:server_in_pool?).with('127.0.0.1', 101).and_return false
        @pen.remove_server('127.0.0.1', 101).should be_true
      end
      
      it "should raise an exception when given server could not be found in the list" do
        lambda {
          @pen.remove_server('127.0.0.2', 100)
        }.should raise_error(ArgumentError)
      end
      
      it "should raise an exception when adding a server that is already in the list" do
        lambda {
          @pen.add_server('127.0.0.1', 100)
        }.should raise_error(ArgumentError)
      end
      
    end
  
    
    describe "managing access control lists" do
      
      before(:each) do
        Penctl.should_receive(:execute).with("127.0.0.1:12000", "control").and_return ["127.0.0.1:12000"]
        @pen = PenBalancer.new '127.0.0.1:12000'
      end
      
      it ":set_acl_entry should set access control list with netmask" do
        Penctl.should_receive(:execute).with("127.0.0.1:12000", "acl 2 permit 192.168.0.1 255.255.255.0")
        @pen.set_acl_entry(2, :policy => 'permit', :source_ip => '192.168.0.1', :netmask => '255.255.255.0')
      end
      
      it ":set_acl_entry should set access control list without netmask" do
        Penctl.should_receive(:execute).with("127.0.0.1:12000", "acl 2 permit 192.168.0.1")
        @pen.set_acl_entry(2, :policy => 'permit', :source_ip => '192.168.0.1')
      end
      
      it ":set_acl_entry should remove access control (allow from all)" do
        Penctl.should_receive(:execute).with("127.0.0.1:12000", "no acl 2")
        @pen.remove_acl_entry(2)
      end
      
      it ":set_acl_entry should raise an exception when given ACL list is out of range [0..9]" do
        lambda {
          @pen.set_acl_entry(10, :policy => 'deny', :source_ip => '127.0.0.1')
        }.should raise_error(RangeError)
      end
    end
  end
end