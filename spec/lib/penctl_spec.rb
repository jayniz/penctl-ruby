require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'lib/penctl'

describe Penctl do
  
  it ":execute should call the penctl binary and contact the right pen" do
    Penctl.should_receive(:'`').with("penctl 127.0.0.1:12000 foo 2>&1").and_return "something\n"
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



__END__

#
#  Takes an attribute name along with a value and returns the value.
#
def self.get_set_attribute(pen, attribute, value)
  value ||= 0
  cmd   = attribute.to_s.chomp '='
  value = attribute.to_s['='] ? " #{value}" : ''
  return Penctl.execute(pen, "#{cmd}#{value}".chomp)[0].to_i # All attributes you can read from penctl are integers
end
