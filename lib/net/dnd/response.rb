module Net
  module DND

    # Container class for fetching and parsing the response lines returned down the socket
    # after a command has been sent to the connected DND server. Checks for good responses
    # as well as error responses.

    # For good responses that contain multiple lines-- fields and lookup commands --it parses
    # those lines into an items array that it makes avaialable back to calling method.

    class Response

      attr_reader :code, :error, :items, :count, :sub_count

      # Constructor method for a Response object. This method is only called directly by
      # our unit tests (specs). Normal interaction with the Response class is via the
      # 'process' class method.

      def initialize(socket)
        @items = []
        @count, @sub_count = 0, 0
        @socket = socket
      end

      # Convenience method for creating a new Response object and automatically parse
      # data items, if they exist.

      def self.process(socket)
        resp = Response.new(socket)
        resp.status_line
        resp.parse_items if [101, 102].include?(resp.code)
        resp
      end

      # Was the result of the last command a 'good' respose?

      def ok?
        /^2../ === code.to_s
      end

      # The first line returned from all command sent to a DND server is the Status Line. The
      # makup of this line not only tells us the success/failuer of the command, but whether
      # there is more data to be read.
      #
      # When there is more data, it will be contained on one or more additional data lines,
      # called 'items' internally. The status line tells us if we have 1 level of n items, or
      # 2 levels of n items, each of which has m sub-items. In the class, n and m are the count
      # and sub_count attributes, respectively.

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

      # The result of our command has told us there are data items that need to be read and
      # parsed. This method sets up the loops used to read the correct number of data lines.
      # If we have a postive sub_count value, we actually build a nested array of arrays,
      # otherwise, we build a single level array of data lines.

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

      # This private method handles the actually reading of the data item lines from the
      # TCP socket. It reads the line and then does a quick parse on it, to return just
      # the data item.

      def data_line
        @socket.gets.chomp.match(/^\d\d\d (.*)/).captures[0]
      end

    end
  end
end
