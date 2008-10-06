require File.dirname(__FILE__) + '/../spec_helper'
require 'net/dnd/session'

module Net ; module DND

  describe Session, "when created with a bad host" do

    before(:each) do
      @connection = flexmock("Bad Connection")
      @connection.should_receive(:open?).once.and_return(false)
      @connection.should_receive(:error).once.and_return("Could not connect to DND server")
      flexmock(Connection).should_receive(:new).once.and_return(@connection)
    end

    it "should raise a Connection Error" do
      lambda { Session.new('my.badhost.com') }.should raise_error(ConnectionError)
    end
  end

  describe Session, "when created with a good host" do

    before(:each) do
      @connection = flexmock("Good Connection")
      @connection.should_receive(:open?).twice.and_return(true)
      flexmock(Connection).should_receive(:new).once.and_return(@connection)
      @session = Session.new('my.goodhost.com')
    end

    it do
      @session.should be_open
    end
  end

  describe Session, "after closing down" do

    before(:each) do
      @connection = flexmock("Good Connection")
      @connection.should_receive(:open?).times(3).and_return(true, true, false)
      flexmock(Connection).should_receive(:new).once.and_return(@connection)
      @response = flexmock(Response)
      @connection.should_receive(:send).once.and_return(@response)
      @session = Session.new('my.goodhost.com')
      @session.close
    end

    it "should not be open" do
      @session.should_not be_open
    end
  end

  describe "a connected session", :shared => true do
    before(:each) do
      @connection = flexmock("Good Connection")
      @connection.should_receive(:open?).twice.and_return(true)
      flexmock(Connection).should_receive(:new).once.and_return(@connection)
    end
  end

  describe "a good response", :shared => true do
    before(:each) do
      @response = flexmock(Response)
      @connection.should_receive(:send).once.and_return(@response)
      @response.should_receive(:ok?).once.and_return(true)
      @session = Session.new('my.goodhost.com')
    end
  end

  describe Session, "when setting fields with an unknown field" do

    it_should_behave_like "a connected session"

    before(:each) do
      @response = flexmock(Response)
      @connection.should_receive(:send).once.and_return(@response)
      @response.should_receive(:ok?).once.and_return(false)
      @response.should_receive(:error).once.and_return('unknown.')
      @session = Session.new('my.goodhost.com')
      @field_list = ['unknown']
    end

    it "should raise a Field Not Found error" do
      lambda { @session.set_fields(@field_list) }.
        should raise_error(FieldNotFound, "unknown.")
    end
  end

  describe Session, "when setting fields with a bad field_list" do

    it_should_behave_like "a connected session"
    it_should_behave_like "a good response"

    before(:each) do
      @field_list = ['ssn']
      @items = ['ssn N N']
      @response.should_receive(:items).once.and_return(@items)
      @ssn_field = flexmock("a bad field")
      @ssn_field.should_receive(:read_all?).once.and_return(false)
      @ssn_field.should_receive(:to_s).once.and_return('ssn')
      flexmock(Field).should_receive(:from_field_line).once.and_return(@ssn_field)
    end

    it "should raise a Field Access Denied error" do
      lambda { @session.set_fields(@field_list) }.
        should raise_error(FieldAccessDenied, "#{@field_list[0]} is not world readable.")
    end
  end

  describe Session, "when setting fields with a good field_list" do

    it_should_behave_like "a connected session"
    it_should_behave_like "a good response"

    before(:each) do
      name_field = flexmock("a name field")
      name_field.should_receive(:read_all?).once.and_return(true)
      name_field.should_receive(:to_sym).once.and_return(:name)
      nickname_field = flexmock("a nickname field")
      nickname_field.should_receive(:read_all?).once.and_return(true)
      nickname_field.should_receive(:to_sym).once.and_return(:nickname)
      flexmock(Field).should_receive(:from_field_line).twice.and_return(name_field, nickname_field)
      @response.should_receive(:items).once.and_return(['name N A', 'nickname U A'])
      @session.set_fields(['name', 'nickname'])
    end

    it "should have [:name, :nickname] as the fields attribute" do
      @session.fields.should == [:name, :nickname]
    end
  end

  describe "mock items for a started session", :shared => true do
    before(:each) do
      name_field = flexmock("a name field")
      name_field.should_receive(:read_all?).once.and_return(true)
      name_field.should_receive(:to_sym).once.and_return(:name)
      nickname_field = flexmock("a nickname field")
      nickname_field.should_receive(:read_all?).once.and_return(true)
      nickname_field.should_receive(:to_sym).once.and_return(:nickname)
      flexmock(Field).should_receive(:from_field_line).twice.and_return(name_field, nickname_field)
      @fields_resp = flexmock(Response)
      @fields_resp.should_receive(:items).once.and_return(['name N A', 'nickname U A'])
      @connection = flexmock("A Started Connection")
      @connection.should_receive(:open?).times(3).and_return(true)
      flexmock(Connection).should_receive(:new).once.and_return(@connection)
    end
  end

  describe Session, "performing a find with no profiles returned" do

    it_should_behave_like "mock items for a started session"

    before(:each) do
      @find_resp = flexmock(Response)
      @find_resp.should_receive(:ok?).once.and_return(true)
      @find_resp.should_receive(:items).once.and_return([])
      @connection.should_receive(:send).twice.and_return(@fields_resp, @find_resp)
      @session = Session.start('my.goodhost.com', ['name', 'nickname'])
      @profiles = @session.find("Nothing returned")
    end

    it "should return an empty array" do
      @profiles.should == []
    end

  end

  describe Session, "performing a find with one profile returned" do

    it_should_behave_like "mock items for a started session"

    before(:each) do
      @find_resp = flexmock(Response)
      @find_resp.should_receive(:ok?).once.and_return(true)
      @find_resp.should_receive(:items).once.and_return([['Joe D. User', 'joey jdu']])
      @joe = flexmock("Joe's Profile")
      flexmock(Profile).should_receive(:new).once.and_return(@joe)
      @connection.should_receive(:send).twice.and_return(@fields_resp, @find_resp)
      @session = Session.start('my.goodhost.com', ['name', 'nickname'])
      @profiles = @session.find("Joe User")
    end

    it "should return a single item array of profiles" do
      @profiles.length.should == 1
    end

    it "should return Joe's profile as the first item" do
      @profiles[0].should equal(@joe)
    end
  end

  describe Session, "performing a find with multiple profiles returned" do

    it_should_behave_like "mock items for a started session"

    before(:each) do
      @joe = flexmock("Joe's Profile")
      @jane = flexmock("Jane's Profile")
      flexmock(Profile).should_receive(:new).twice.and_return(@joe, @jane)
      @find_resp = flexmock(Response)
      @find_resp.should_receive(:ok?).once.and_return(true)
      @find_resp.should_receive(:items).once.
                and_return([['Joe D. User', 'joey jdu'],['Jane P. User', 'janey jpu']])
      @connection.should_receive(:send).twice.and_return(@fields_resp, @find_resp)
      @session = Session.start('my.goodhost.com', ['name', 'nickname'])
      @profiles = @session.find("User")
    end

    it "should return a 2 item array of profiles" do
      @profiles.length.should == 2
    end

    it "should return Jane's profile as the second item" do
      @profiles[1].should equal(@jane)
    end
  end

  describe Session, "performing an bad single find" do

    it_should_behave_like "mock items for a started session"

    before(:each) do
      @find_resp = flexmock(Response)
      @find_resp.should_receive(:ok?).once.and_return(true)
      @find_resp.should_receive(:items).once.and_return([])
      @connection.should_receive(:send).twice.and_return(@fields_resp, @find_resp)
      @session = Session.start('my.goodhost.com', ['name', 'nickname'])
      @profile = @session.find("Nothing", :one)
    end

    it "should return nil for the profile object" do
      @profile.should be_nil
    end
  end

  describe Session, "performing a good single find" do

    it_should_behave_like "mock items for a started session"

    before(:each) do
      @find_resp = flexmock(Response)
      @find_resp.should_receive(:ok?).once.and_return(true)
      @find_resp.should_receive(:items).twice.and_return([['Joe D. User', 'joey jdu']])
      @joe = flexmock("Joe's Profile")
      flexmock(Profile).should_receive(:new).once.and_return(@joe)
      @connection.should_receive(:send).twice.and_return(@fields_resp, @find_resp)
      @session = Session.start('my.goodhost.com', ['name', 'nickname'])
      @profile = @session.find("Joe User", :one)
    end

    it "should return Joe's profile" do
      @profile.should equal(@joe)
    end
  end

end ; end