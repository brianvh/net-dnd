require 'socket'
require 'timeout'

folder_path = File.dirname(__FILE__)

require "#{folder_path}/profile"
require "#{folder_path}/user_spec"
require "#{folder_path}/field"
require "#{folder_path}/command_io"

module Net ; module DND
  
  class Session
    
    PORT = 902
    
    attr_reader :host, :socket, :fields
    
    def initialize(host, fields=[])
      @host = host
      @socket = timeout(5) { TCPSocket.open(@host, PORT) }
      @socket.extend(CommandIo)
      field_lines = @socket.get_fields(fields)
      @fields = field_lines.map { |f| Net::DND::Field.from_field_line(f) }
    end
    
  end
  
end ; end
