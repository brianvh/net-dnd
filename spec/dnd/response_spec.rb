require File.dirname(__FILE__) + '/../spec_helper'
require 'net/dnd/response'

module Net ; module DND

  describe "A new Response object" do

    before(:each) do
      @socket = flexmock("TCP Socket")
      @response = Response.new(@socket)
    end

    it "should have no :code value" do
      @response.code.should be_nil
    end

    it "should have no :error value" do
      @response.error.should be_nil
    end

    it "should have an empty :items value" do
      @response.items.should be_empty
    end

    describe "after getting initial status" do

      before(:each) do
        @socket.should_receive(:gets).once.and_return('220 DND server ready.')
        @response.status_line
      end

      it "should have a :code of 220" do
        @response.code.should == 220
      end

      it do
        @response.should be_ok
      end

      describe "- responding to bad :fields method" do
        before(:each) do
          @code = 501
          @msg = "unknown field name foo"
          @socket.should_receive(:gets).once.and_return("#{@code} #{@msg}\r\n")
          @response.status_line
        end

        it "should return a code of 501" do
          @response.code == @code
        end

        it "should have the appropriate error message" do
          @response.error == @msg
        end

        it do
          @response.should_not be_ok
        end
      end

      describe "- responding to good :fields method" do
        before(:each) do
          @code = 102
          @count = 2
          @socket.should_receive(:gets).once.and_return("#{@code} #{@count}\r\n")
          @response.status_line
        end

        it "should have a code of 102" do
          @response.code == @code
        end

        it "should have a count of 1" do
          @response.count == @count
        end

        it "should have a sub_count of 0" do
          @response.sub_count == 0
        end
      end

      describe "- parsing :fields items" do
        before(:each) do
          @code = [102, 200]
          @count = 2
          @data = ['120 name N A', '120 nickname U A']
          @status = 'Done'
          @socket.should_receive(:gets).times(4).and_return(
              "#{@code[0]} #{@count}\r\n", "#{@data[0]}\r\n",
              "#{@data[1]}\r\n", "#{@code[1]} Done\r\n")
          @response.status_line
          @response.parse_items
        end

        it "should have the correct number of items" do
          @response.items.length == 2
        end

        it "should have 'nickname' as the second item" do
          @response.items[1].split[0] == 'nickname'
        end

        it "should have a :code of 200" do
          @response.code.should == @code[1]
        end

        it do
          @response.should be_ok
        end
      end

      describe "- responding to good :lookup method" do
        before(:each) do
          @code = 101
          @count = 2
          @sub_count = 2
          @socket.should_receive(:gets).once.and_return("#{@code} #{@count} #{@sub_count}\r\n")
          @response.status_line
        end

        it "should have a code of 101" do
          @response.code == @code
        end

        it "should have a count of 2" do
          @response.count == @count
        end

        it "should have a sub_count of 2" do
          @response.sub_count == @sub_count
        end
      end

      describe "- parsing :lookup items" do
        before(:each) do
          @code = [102, 201]
          @count = 2
          @sub_count = 2
          @data = ['110 Joe Q. User', '110 joey, jqu', '110 Jane P. User', '110 janes, jp']
          @status = 'Additional matches not returned'
          @socket.should_receive(:gets).times(6).and_return(
              "#{@code[0]} #{@count} #{@sub_count}\r\n",
              "#{@data[0]}\r\n", "#{@data[1]}\r\n",
              "#{@data[2]}\r\n", "#{@data[3]}\r\n",
              "#{@code[1]} #{@status}\r\n")
          @response.status_line
          @response.parse_items
        end
      
        it "should have the correct number of data items" do
          @response.items.length == 2
        end
      
        it "should have arrays as the outer items" do
          @response.items[0].should be_an_instance_of(Array)
        end
      
        it "should have the correct name for the second item array" do
          @response.items[1][0] == 'Jane P. User'
        end
      
        it "should have a :code of 201" do
          @response.code.should == @code[1]
        end
      
        it do
          @response.should be_ok
        end
      end

    end

  end

end; end