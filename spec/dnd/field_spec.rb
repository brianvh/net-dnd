require File.dirname(__FILE__) + '/../spec_helper'
require 'net/dnd/field'

module Net ; module DND
  
  describe Field, "created normally" do
    before :each do
      @name, @write, @read = %w(nickname U A)
      @field = Field.new(@name, @write, @read)
    end
    
    it "should properly set the writeable flag" do
      @field.writeable.should == @write
    end
    
    it "should properly set the readable flag" do
      @field.readable.should == @read
    end
    
    it "should report as readable by all if readable value is 'A'" do
      @field.should be_read_all
    end
    
    it "should report back the proper name" do
      @field.name.should == @name
    end
    
    it "should report back the proper inspection string" do
      @field.inspect.should match(/<Net::DND::Field name=".*" writeable="[AUNT]" readable="[AUNT]">/)
    end
    
    it "should return the name when coerced to a string" do
      @field.to_s.should == @name
    end
    
    it "should return :name when coerced to a symbol" do
      @field.to_sym.should == @name.to_sym
    end
    
    it "should not report as readable by all if readable value is not 'A'" do
      @read = "T"
      @field = Field.new(@name, @write, @read)
      @field.should_not be_read_all
    end
    
  end
  
  describe Field, "created using from_field_line with a proper line format" do

    before(:each) do
      @values = %w(nickname U A)
      line = @values.join(" ")
      @field = Field.from_field_line(line)
    end

    it "should have the correct name" do
      @field.name.should == @values[0]
    end

    it "should have to correct readable value" do
      @field.readable.should == @values[2]
    end
  end
  
  describe Field, "created using from_field_line with an improper line format" do
    it "should raise the proper error" do
      line = "This is a bad field line"
      lambda { Field.from_field_line(line) }.should raise_error(FieldLineInvalid)
    end
  end
  
end ; end