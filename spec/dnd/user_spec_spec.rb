require File.dirname(__FILE__) + '/../spec_helper'
require 'net/dnd/user_spec'

module Net ; module DND
  
  describe UserSpec, "- with a normal (i.e. name) specifier" do
    before :each do
      @name = "Joe D. User"
      @spec = UserSpec.new @name
    end
    
    it "should report a specifier type of :name" do
      @spec.type.should == :name
    end
    
    it "should return just the supplied specifier when coerced to a string" do
      @spec.to_s.should == @name
    end
  end
    
  describe UserSpec, "- with a UID specifier" do
    before :each do
      @uid = "123456"
      @spec = UserSpec.new @uid
    end
    
    it "should report a specifier type of :uid" do
      @spec.type.should == :uid
    end
    
    it "should return the specifier, with leading \"#\", when coerced to a string" do
      @spec.to_s.should == "##{@uid}"
    end

    it "should return the correct inspection string" do
      @spec.inspect.should match(/<Net::DND::UserSpec specifier="\d+" type=\:.+>/)
    end
  end
    
  describe UserSpec, "- a standard DID specifier" do
    before :each do
      @did = "12345A"
      @spec = UserSpec.new @did
    end
    
    it "should report a specifier type of :did" do
      @spec.type.should == :did
    end
    
    it "should return the specifier, with leading \"#*\", when coerced to a string" do
      @spec.to_s.should == "#*#{@did}"
    end
  end
    
  describe UserSpec, "- with a non-standard DID specifier" do
    before :each do
      @did = "Z12345"
      @spec = UserSpec.new @did
    end
    
    it "should report a specifier type of :did" do
      @spec.type.should == :did
    end
    
    it "should return the specifier, with leading \"#*\", when coerced to a string" do
      @spec.to_s.should == "#*#{@did}"
    end
  end
  
end ; end
