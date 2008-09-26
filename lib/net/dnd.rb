$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../../lib"
require "net/dnd/session"

module Net
  
  # Inspired by the great work done by Jamis Buck on the Net::SSH library, this new
  # version of Net::DND aims to be a much better library for interacting with the
  # Dartmouth Name Directory (DND) protocol.
  #
  # In this first release, the focus is still on providing primarily lookup access, but
  # the architecture has been re-worked to allow for fairly easy support of the rest of
  # the DND protocol, should the need ever arise.
  #
  # Contained here in the module wrapper file, is the start method, which allows for easy
  # session/connection management. The intent is to call this method with a block construct,
  # like this:
  #
  #   Net::DND.start("your.dnd.server", fields) do |dnd|
  #     profile = dnd.lookup("some user")
  #   end
  #
  # All calls to the lookup command, in it's various guises, are intented to return
  # Net::DND::Profile objects. The profile object(s) will contain attr_reader methods for
  # the fields specified in the start call, or a full set of publicly viewable fields from
  # the partiuclar DND server being accessed.
  
  module DND
    
    def self.start(host, fields=[], &block)
      session = Session.start(host, fields)
      if block_given?
        yield session
        session.close
      else
        return session
      end
    end
    
  end
  
  # Convenience modules and start methods for the three most commonly accessed DND hosts.
  # Basically, so you don't need to remeber the host name, as long as you know which module
  # to call for which DND server to which you want to send lookup commands.
  
  module DartmouthDND
    
    HOST = 'dnd.dartmouth.edu'
    def self.start(fields=[], &block)
      DND.start(HOST, fields, &block)
    end
    
  end
  
  module AlumniDND
    
    HOST = 'dnd.dartmouth.org'
    def self.start(fields=[], &block)
      DND.start(HOST, fields, &block)
    end
    
  end
  
  module HitchcockDND
    
    HOST = 'dnd.hitchcock.org'
    def self.start(fields=[], &block)
      DND.start(HOST, fields, &block)
    end
    
  end
end
