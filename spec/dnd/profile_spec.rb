require File.dirname(__FILE__) + '/../spec_helper'
require 'net/dnd/profile'

module Net ; module DND

  describe Profile, "for Joe D. User" do

    before(:each) do
      @fields = [:name, :nickname, :deptclass, :email]
      @items = ['Joe D. User', 'joey jdu', 'Student', 'Joe.D.User@Dartmouth.edu']
      @profile = Profile.new(@fields, @items)
    end

    it "should return the correct object" do
      @profile.should be_instance_of(Profile)
    end

    it "should have the correct number of entries" do
      @profile.length.should == 4
    end

    it "should return the correct name" do
      @profile.name.should == @items[0]
    end

    it "should return the correct email" do
      @profile[:email].should == @items[3]
    end

    it "should contain nickname field" do
      @profile.should be_nickname
    end

    it "should not contain did field" do
      @profile.should_not be_did
    end

    it "should raise an error if did field is requested" do
      lambda { @profile.did }.should raise_error(RuntimeError)
    end

  end

end ; end