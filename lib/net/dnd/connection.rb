require 'socket'
require 'timeout'

folder_path = File.dirname(__FILE__)
require "#{folder_path}/user_spec"
require "#{folder_path}/response"

module Net ; module DND

  class Connection

    PORT = 902

    attr_reader :host, :socket, :error, :response

    def initialize(hostname)
      @host = hostname
      @open = false
      begin
        @socket = Timeout::timeout(5) { TCPSocket.open(host, PORT) }
      rescue Timeout::Error
        @error = "Connection attempt to DND server on host #{host} has timed out."
        return
      rescue Errno::ECONNREFUSED
        @error = "Could not connect to DND server on host #{host}."
        return
      end
      @response = Response.new(socket)
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
      @response = Response.new(socket)
    end

  end
  
end ; end
