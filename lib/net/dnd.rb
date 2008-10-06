$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../../lib"
require "net/dnd/session"

module Net
  
  # Inspired by the outstanding work done by Jamis Buck on the Net::SSH family of gems/libraries,
  # this new version of Net::DND aims to be a much better interface for working with the
  # Dartmouth Name Directory (DND) protocol.
  #
  # In the first (1.0.0) release, the focus is still on providing primarily user finding
  # facilites, however, the architecture has been re-worked to allow for fairly easy support
  # of the rest of the DND protocol, should the need ever arise.
  #
  # Contained here, in the module/librtary wrapper file, is the primary 'start' method, which
  # allows for straightforward session/connection management. The intent is to call this method
  # with a block construct, like this:
  #
  #   Net::DND.start("your.dnd.server", fields) do |dnd|
  #     profile = dnd.find("some user")
  #   end
  #
  # But you don't need to use the block version. You can simply call the start method and it
  # will return a DND session object. You can then send find commands to that object. Used in
  # this way, you have to remember to explicitly close the DND session, as below:
  #
  #   dnd = Net::DND.start('dnd.dartmouth.edu', %w(name nickname uid))
  #   profile = dnd.find('Throckmorton Scribblemonger', :one)
  #   dnd.close
  #   puts profile.nickname
  #    > throckie
  #
  # All calls to the find command, whether it's restricted to a single match or not, will return
  # Net::DND::Profile objects. The profile object(s) will contain getter methods for the
  # field names specified in the start call. If no fields are supplied, the DND session, and
  # therefore all returned profile objects will contain the full set of publicly viewable fields
  # from the partiuclar DND server to which you've connected.
  
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
  # Basically, so you don't need to remeber the exact host name, as long as you know which
  # version of the start method to call for the DND server to which you want to send finds.
  
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
