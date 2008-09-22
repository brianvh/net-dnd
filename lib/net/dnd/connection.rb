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

      def open?
        @open
      end

      def fields(field_list=[])
        cmd = "fields #{field_list.join(' ')}".rstrip
        read_response(cmd)
      end

      def lookup(user, field_list)
        user_spec = UserSpec.new(user)
        cmd = "lookup #{user_spec.to_s},#{field_list.join(' ')}"
        read_response(cmd)
      end

      def quit
        cmd = "quit"
        read_response(cmd)
        @socket.close
      end

      private

      def read_response(cmd="noop")
        socket.puts(cmd)
        @response = Response.process(socket)
      end

    end
  end
end
