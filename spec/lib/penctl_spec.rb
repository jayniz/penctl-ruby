require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'lib/penctl'

describe Penctl do
  
  it ":execute should call the penctl binary and contact the right pen" do
    socket = mock("socket")
    socket.should_receive(:puts).with "foo"
    socket.should_receive(:gets).and_return "something"
    socket.should_receive(:gets).and_return false
    socket.should_receive(:close)
    TCPSocket.should_receive(:open).with("127.0.0.1", 12000).and_return socket
    Penctl.execute( "127.0.0.1:12000", "foo").should == ["something"]
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
    Penctl.parse_server_line(line).should == expected
  end
  
  it ":update_server should change server settings" do
    Penctl.should_receive(:execute).with("127.0.0.1:12000", "server 1 address 127.0.0.1 port 88")
    Penctl.update_server '127.0.0.1:12000', 1, :address => '127.0.0.1', :port => 88
  end
  
  it ":set_boolean_attribute should turn true into the right penctl command" do
    Penctl.should_receive(:execute).with("127.0.0.1:12000", "foo")
    Penctl.set_boolean_attribute('127.0.0.1:12000', 'foo', true)
  end
  
  it ":set_boolean_attribute should turn true into the right penctl command" do
    Penctl.should_receive(:execute).with("127.0.0.1:12000", "no foo")
    Penctl.set_boolean_attribute('127.0.0.1:12000', 'foo', false)
  end

  it ":get_set_attribute should set some attribute's value" do
    Penctl.should_receive(:execute).with("127.0.0.1:12000", "foo bar").and_return ["0"]
    Penctl.get_set_attribute('127.0.0.1:12000', 'foo=', 'bar')
  end
  
  it ":get_set_attribute should get some attribute's value" do
    Penctl.should_receive(:execute).with("127.0.0.1:12000", "foo").and_return ["0"]
    Penctl.get_set_attribute('127.0.0.1:12000', 'foo')
  end
end