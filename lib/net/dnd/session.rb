folder_path = File.dirname(__FILE__)

require "#{folder_path}/protocol/session"
require "#{folder_path}/profile"

module Net ; module DND
  
  # This is the DND session object. It provides the high-level interface for performing
  # lookup-style searches against a given DND host. It manages the Protocol Session object,
  # which is the low-level TCP stuff and sends back DND Profile objects, either singly or
  # an array as the result of all find an find_one calls.
  
  class Session
    
    attr_reader :fields, :protocol
    
    def initialize(host, field_list=[])
      @protocol = Protocol.new(host)
      raise protocol.error unless protocol.open?
      @fields = []
      set_fields(field_list)
    end
    
    def set_fields(field_list=[])
      response = request(:fields, field_list)
      response.items.each { |item| @fields << item.to_sym }
    end
    
    def find(lookup_string)
      response = request(:lookup, lookup_string.to_s, fields)
      found_ary = []
      response.items.each { |item| found_ary << Profile.new(fields, item) }
      found_ary
    end
    
    def find_one(lookup_string)
      response = request(:lookup, lookup_string.to_s, fields)
      Profile.new(fields, response.items)
    end
    
    def close
      request(:quit, nil)
    end
    
    private
    
      def request(type, *args)
        raise "Connection closed." if protocol.closed?
        response = protocol.send(type, *args)
        raise response.error unless response.ok?
        response
      end
    
  end
  
end ; end
