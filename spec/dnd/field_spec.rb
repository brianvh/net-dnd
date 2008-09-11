require File.dirname(__FILE__) + '/../spec_helper'
require 'net/dnd/protocol/field'

module Net ; module DND
  
  describe Field do
    
    describe "- when created normally" do
      before :each do
        @name, @write, @read = %w(nickname U A)
        @field = Field.new(@name, @write, @read)
      end
      
      it "should report back the proper name" do
        @field.name.should == @name
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
      
      it "should not report as readable by all if readable value is not 'A'" do
        @read = "T"
        @field = Field.new(@name, @write, @read)
        @field.should_not be_read_all
      end
      
      it "should throw an error on an invalid writable value" do
        @write = "Q"
        lambda { Field.new(@name, @write, @read) }.should raise_error(RuntimeError)
      end
    end
    
    describe "created using from_field_line with a proper line format" do
      it "should parse into the proper values" do
        @values = %w(nickname U A)
        line = @values.join(" ")
        @field = Field.from_field_line(line)
        @field.name.should == @values[0]
        @field.readable.should == @values[2]
      end
    end
    
    describe "created using from_field_line with an improper line format" do
      it "should raise an error" do
        line = "This is a bad field line"
        lambda { Field.from_field_line(line) }.should raise_error(RuntimeError)
      end
    end
  end
  
end ; end