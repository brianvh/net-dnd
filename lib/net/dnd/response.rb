
module Net ; module DND

  class Response

    attr_reader :code, :error, :items, :count, :sub_count

    def initialize(socket)
      @items = []
      @count, @sub_count = 0, 0
      @socket = socket
    end

    def self.process(socket)
      new(socket)
      status_line
      parse_items if [101, 102].include?(code)
      self
    end

    def ok?
      /^2../ === code.to_s
    end
    
    def status_line
      line = @socket.gets.chomp
      @code = line.match(/^(\d\d\d) /).captures[0].to_i
      case @code
        when /^2../ # Command successful, ready for next
          true
        when /^5../ # Command error, set the error value to the line text
          @error = line.match(/^\d\d\d (.*)/).captures[0]
        when 101, 102 # Data command status, set the count and sub_count values
          counts = line.match(/^\d\d\d (\d+) *(\d*)/).captures
          @count = counts[0].to_i
          @sub_count = counts[1].to_i
      end
    end
    
    def parse_items
      count.times do # loop at least count times
        if sub_count > 0 # do we have an inner loop
          sub_ary = []
          sub_count.times { sub_ary << data_line }
          @items << sub_ary
        else
          @items << data_line
        end
      end
      status_line
    end
    
    private
      
    def data_line
      @socket.gets.chomp.match(/^\d\d\d (.*)/).captures[0]
    end

  end

end ; end
