require File.dirname(__FILE__) + '/../spec_helper'
require 'net/dnd/connection'

module Net ; module DND

  describe "a good socket", :shared => true do
    before(:each) do
      @socket = flexmock("TCP Socket")
      @tcp = flexmock(TCPSocket)
      @response = flexmock(Response)
    end
  end

  describe Connection, "to a bad host" do

    it_should_behave_like "a good socket"

    before(:each) do
      @tcp.should_receive(:open).and_raise(Errno::ECONNREFUSED, "Connection refused")
      @connection = Connection.new('my.fakehost.com')
    end

    it "should not indicate an open connection" do
      @connection.should_not be_open
    end

    it "should return the 'Could not connect' error message" do
      @connection.error.should match(/^Could not connect to/)
    end
  end

  describe Connection, "to a busy/slow host" do

    it_should_behave_like "a good socket"

    before(:each) do
      flexmock(Timeout).should_receive(:timeout).and_raise(Timeout::Error, "Connection timed out")
      @connection = Connection.new('my.slowhost.com')
    end

    it "should not indicate an open connection" do
      @connection.should_not be_open
    end

    it "should return the 'Connection timed out' error message" do
      @connection.error.should match(/^Connection attempt .* has timed out/)
    end
  end

  describe Connection, "to a good host" do

    it_should_behave_like "a good socket"

    before(:each) do
      @tcp.should_receive(:open).once.and_return(@socket)
      @response.should_receive(:new).at_least.once.and_return(@response)
      @response.should_receive(:ok?).at_least.once.and_return(true)
      @connection = Connection.new('my.goodhost.com')
    end

    it "should indicate an open connection" do
      @connection.should be_open
    end

    it "should not have any error messages" do
      @connection.error.should be_nil
    end

    describe "sending commands" do

      it "should send the correct command when fields is called with empty field list" do
        @socket.should_receive(:puts).once.with('fields')
        @connection.fields
      end

      it "should send the correct command when fields is called with a field list" do
        @socket.should_receive(:puts).once.with('fields name nickname')
        @connection.fields(['name', 'nickname'])
      end

      it "should send the correct command when lookup is called" do
        @socket.should_receive(:puts).once.with('lookup joe user,name nickname')
        @connection.lookup('joe user', ['name', 'nickname'])
      end

      it "should send the correct command when quit is called" do
        @socket.should_receive(:puts).once.with('quit')
        @socket.should_receive(:close)
        @connection.quit
      end
    end
  end

end ; end