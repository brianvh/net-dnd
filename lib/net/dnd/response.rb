module Net
  module DND

    # Container class for fetching and parsing the response lines returned down the socket
    # after a command has been sent to the connected DND server. Checks for good responses
    # as well as error responses.

    # For good responses that contain multiple lines-- fields and lookup commands --it parses
    # those lines into an items array that it makes avaialable back to calling method.

    class Response

      attr_reader :code, :error, :items, :count, :sub_count

      def initialize(socket)
        @items = []
        @count, @sub_count = 0, 0
        @socket = socket
      end

      # Convenience method for creating a new Response object and automatically parsing multiple
      # returned items if they exist.
      def self.process(socket)
        resp = Response.new(socket)
        resp.status_line
        resp.parse_items if [101, 102].include?(resp.code)
        resp
      end

      def ok?
        /^2../ === code.to_s
      end

      def status_line
        line = @socket.gets.chomp
        @code = line.match(/^(\d\d\d) /).captures[0].to_i
        case code
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
  end
end
