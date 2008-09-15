require File.dirname(__FILE__) + '/../spec_helper'
require 'net/dnd/connection'

module Net ; module DND

  describe Connection do

    before(:each) do
      @socket = flexmock("TCP Socket")
      @tcp = flexmock(TCPSocket)
      @response = flexmock(Response)
    end
    
    describe "- when connecting to a bad host" do
    
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

    describe "- when connecting to a busy/slow host" do
    
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

    describe "- when connected to a good host" do

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

      describe "- and sending commands to the socket" do
        before(:each) do
          @socket.should_receive(:puts).once.and_return(nil)
        end

        it "should send the correct command when fields is called with empty field list" do
          @connection.fields
          @connection.command.should == 'fields'
        end

        it "should send the correct command when fields is called with a field list" do
          @connection.fields(['name', 'nickname'])
          @connection.command.should == 'fields name nickname'
        end

        it "should send the correct command when lookup is called" do
          @connection.lookup('joe user', ['name', 'nickname'])
          @connection.command.should == 'lookup joe user,name nickname'
        end

        it "should send the correct command when quit is called" do
          @socket.should_receive(:close).and_return(nil)
          @connection.quit
          @connection.command.should == 'quit'
        end
      end

    end

  end

end ; end