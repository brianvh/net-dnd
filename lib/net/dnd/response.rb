
module Net ; module DND

  class Response

    attr_reader :code, :error, :items, :count, :sub_count, :state

    def initialize(socket)
      @items = []
      @count, @sub_count = 0, 0
      @socket = socket
      get_status
      parse_items if state == :data
    end
    
    def ok?
      state == :ok
    end
    
    def parse_items
      count.times do # loop at least count times
        if sub_count > 0 # do we have an inner loop
          sub_ary = []
          sub_count.times { sub_ary << next_data_line }
          @items << sub_ary
        else
          @items << next_data_line
        end
      end
      get_status
    end
    
    private
      
    def next_data_line
      @socket.gets.chomp.match(/^\d\d\d (.*)/).captures[0]
    end
    
    def get_status
      line = @socket.gets.chomp
      @code = line.match(/^(\d\d\d) /).captures[0].to_i
      @state = case @code
        when /^2../ # Command successful, ready for next
          :ok
        when /^5../ # Command error, set the error value to the line text
          @error = line.match(/^\d\d\d (.*)/).captures[0]
          :error
        when 101, 102 # Data command status, set the count and sub_count values
          counts = line.match(/^\d\d\d (\d+) *(\d*)/).captures
          @count = counts[0].to_i
          @sub_count = counts[1].to_i
          :data
      end
    end
  end

end ; end
