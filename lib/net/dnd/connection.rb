require 'socket'
require 'timeout'

folder_path = File.dirname(__FILE__)
require "#{folder_path}/user_spec"
require "#{folder_path}/response"

module Net
  module DND

    # An internal class, used by the Session object, to manage the TCP Socket connection
    # to the requested DND server. The Connection object contains the low-level protocol
    # commands that are actually composed and sent down the socket. Once a command is sent
    # the Connection object instantiates a new Response object to parse the returned data.
    # The Response object is sent back to the Session as the result of calling the fields
    # and lookup methods. The quit method is used to close down the socket connection. It
    # doesn't actually return anything back to the Session.
    class Connection

      attr_reader :host, :socket, :error, :response

      # Initialize the TCP connection to be used by the Session. Will raise errors if
      # there's no response from port 902 on the supplied host, or if the connection
      # attempt times out. This constructor also verifies that the connected DND server
      # is ready to respond to protocol commands.

      def initialize(hostname)
        @host = hostname
        @open = false
        begin
          @socket = Timeout::timeout(5) { TCPSocket.open(host, 902) }
        rescue Timeout::Error
          @error = "Connection attempt to DND server on host #{host} has timed out."
          return
        rescue Errno::ECONNREFUSED
          @error = "Could not connect to DND server on host #{host}."
          return
        end
        @response = Response.process(socket)
        @open = @response.ok?
      end

      # Is the TCP socket still open/active?

      def open?
        @open
      end

      # Low-level protocol command for verifying a list of supplied fields. If no fields are
      # supplied, the fields command will return verification data for all known fields.

      def fields(field_list=[])
        cmd = "fields #{field_list.join(' ')}".rstrip
        read_response(cmd)
      end

      # Low-level protocol command for performing a 'find' operation. Takes a user specifier
      # and a list of fields.

      def lookup(user, field_list)
        user_spec = UserSpec.new(user)
        cmd = "lookup #{user_spec.to_s},#{field_list.join(' ')}"
        read_response(cmd)
      end

      # Low-level protocol command for telling the DND server that you are closing the connection.
      # Calling this method on the socket also closes the session's TCP connection.

      def quit(noargs = nil)
        cmd = "quit"
        read_response(cmd)
        @socket.close
        response
      end

      private

      # Private method for sending the protocol commands across the socket. Also handles the
      # dispatching of any returned data to the Net::DND::Response class for processing.

      def read_response(cmd="noop")
        socket.puts(cmd)
        @response = Response.process(socket)
      end

    end
  end
end
