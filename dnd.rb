# = net/dnd.rb
#
# Copyright (c) 2006 Trustees of Dartmouth College
#
# Written & maintained by Brian V. Hughes <brianvh@dartmouth.edu>
#
# Borrowed heavily from net/smtp.rb and net/pop.rb
# Will need some cleanup, but this is just the 0.3 version
#
# Extending the Net module was done because of the close ties, from an Internet protocol
# standpoint with POP and SMTP. Also, using net/protocol as the base class gives us access
# to very good TCP/IP session and stream methods, thus shortening the overall length of the
# module.
#
# At this point in time, the DND class is just a big wrapper for doing one or more lookups
# within the context of a single DND server session. This closely follows the methodology used
# with SMTP and connecting to send one or more email messages. But, the module extension was
# built out enough, such that additional methods could be developed to allow for more DND
# interaction.
#
# At the bottom of this script file is a custom class for modeling a DND User's profile. This
# was needed to make accessing the data returned from a lookup command more object based.
#
# $Id: dnd.rb, v 0.4 2006/01/16 BVH
#

require 'net/protocol'

module Net

  # Set up the error handling classes...
  class DNDError < ProtocolError
  end
  class DNDUserNotFound < DNDError
  end
  class DNDBadFieldName < DNDError
  end
  class DNDUserNameTooShort < DNDError
  end
  class DNDFieldAccessDenied < ProtoSyntaxError
  end
  class DNDUnknownError < ProtoUnknownError
  end

  class DND < Protocol
    Revision = %q$Revision: 0.4 $.split[1]
    
    def DND.default_port
      902
    end

    def initialize( host, port = nil, fields = [])
      @host = host
      @port = port || DND.default_port
      
      @fields = fields
      @profiles = []
      
      @socekt = nil
      @started = false
      @open_timeout = 30
      @read_timeout = 60
      
      @error_occured = false
      @debug_output = false
    end

    def inspect
      "#<#{self.class} #{@host}:#{@port} open=#{@started} fields=#{@fields.inspect}>"
    end

    attr_reader :address, :port, :open_timeout, :read_timeout

    def set_debug_output( arg )
      @debug_output = arg
    end

    #
    # DND Session Control
    #

    #
    # This method creates a new Net::DND object, connects to the specified server
    # and populates the @fields array. If the fields argument array is present, and 
    # contains readable fields, then only those fields will be available for the 
    # length of the current session.
    #
    # This method is equivalent to:
    #
    #   Net::DND.new(host, port, fields).start
    #
    # The intent is to call this method with a block construct, like this:
    #
    #   Net::DND.start("your.dnd.server") do |dnd|
    #     profile = dnd.lookup("some user")
    #   end
    #
    # This method may raise:
    # # Net::DNDError
    # # Net::DNDUnknownError
    # # IOError
    # # TimeoutError
    #
    def DND.start( host, port = nil, fields = [], &block) # :yield: dnd
      new(host, port, fields).start(&block)
    end

    def started?
      @started
    end

    # This is the method you would call if you decided to use DND.new to start the session.
    # You can also pass a block to this command, but it's assumed to be more conventient to use
    # DND.start method if you want to use the block construct.
    #
    # The actual DND session is started by the private do_start method
    #
    def start
      if block_given?
        begin
          do_start
          return yield(self)
        ensure
          do_finish
        end
      else
        do_start
        return self
      end
    end

    def do_start
      raise IOError, 'DND session already started' if @started
      # Changed for Ruby 1.8.4... 20-Apr-06. BVH.
      @socket = InternetMessageIO.respond_to?(:old_open) ?
                InternetMessageIO.old_open(@host, @port, @open_timeout, @read_timeout, @debug_output) :
                InternetMessageIO.open(@host, @port, @open_timeout, @read_timeout, @debug_output)
      check_response(critical { recv_response() }) # check the server response
      begin
        get_fields
      rescue DNDError
        @error_occured = true
      end
      @started = true
    ensure
      @socket.close if not @started and @socket and not @socket.closed?
    end
    private :do_start

    # Finishes the DND session and closes TCP connection.
    # Raises IOError if not started.
    def finish
      raise IOError, 'not yet started' unless started?
      do_finish
    end

    def do_finish
      quit if @socket and not @socket.closed? and not @error_occured
    ensure
      @started = false
      @error_occured = false
      @socket.close if @socket and not @socket.closed?
      @socket = nil
    end
    private :do_finish

    public

    # This is the basic lookup method. A user_spec is passed in and an array is returned.
    # The array is populated with DNDProfile items for each match returned. Each DNDProfile
    # contains attributes/methods for each field in the @fields array.
    #
    # This method may raise:
    #
    # # Net::DNDUserNotFound
    # # Net::DNDUserNameTooShort
    #
    def lookup( user )
      users = []
      user_count, field_count = get_response_count( 'LOOKUP %s,%s',
                                                    user_spec(user),
                                                    @fields.join(" "))
      user_count.times do |u|
        data = []
        field_count.times do |f|
          data << get_data_line('110')
        end
        users << DNDProfile.new(@fields, data)
      end
      check_response(critical { recv_response() }) # check the LOOKUP command closure
      users
    end

    # The lookup_one method (0.4) is based off the lookup method, but it's goal it to
    # return a single DNDProfile object back to the parent object. If there's more
    # than a single match, the method retuns a nil.
    #
    # This method may raise:
    #
    # # Net::DNDUserNotFound
    # # Net::DNDUserNameTooShort
    #
    def lookup_one( user )
      user_count, field_count = get_response_count( 'LOOKUP %s,%s',
                                                    user_spec(user),
                                                    @fields.join(" "))
      return nil unless user_count == 1
      data = []
      field_count.times do |f|
        data << get_data_line('110')
      end
      check_response(critical { recv_response() }) # check the LOOKUP command closure
      DNDProfile.new(@fields, data)
    end

    #
    # DND command dispatchers
    #

    private

    # The user_spec method is used by the lookup_user command. It's role is to
    # properly format the lookup query string, normally a user name, in those cases
    # where a DND UID (#user) or DND DCTSNUM (#*user) are passed in.
    def user_spec ( user )
      return "##{user}" if /^\d+$/.match(user)
      return "#*#{user}" if /^z\d+$/.match(user.downcase) # added for 0.2
      return "#*#{user}" if /^\d+[a-z]\d*$/.match(user.downcase)
      user
    end

    # Private method, called by start, that populates the @fields array. Since only
    # fields flagged as "Read by Any" (A) can be looked up, only those fields are 
    # allowed in the @fields array.
    #
    # This method may raise:
    #
    # # Net::DNDFieldAccessDenied
    #
    def get_fields
      field_count = get_response_count( 'FIELDS %s ', @fields.join(" "))
      field_list = []
      field_count.times do |f|
        fl = get_data_line('120').split
        raise DNDFieldAccessDenied if @fields.include?(fl[0]) and fl[2] != 'A'
        field_list << fl[0] if fl[2] == 'A'
      end
      check_response(critical { recv_response() }) # check the FIELDS command closure
      @fields = field_list
    end

    def quit
      check_response(critical {get_response( 'QUIT' )} )
    end

    #
    # Socket response handlers. The get_response_count and get_data_line methods are specific
    # to the way the DND protocol communicated. The other methods are basically carbon copies of
    # the same methods found in net/smtp and net/pop.
    #

    private

    def get_response_count( fmt, *args )
      res = check_response(critical {get_response(fmt, *args)})
      counts = res.split
      return counts[1].to_i, counts[2].to_i if counts.size == 3
      return counts[1].to_i
    end

    def get_data_line( code )
      res = check_response(critical {recv_response})
      res_code, res_data = res.match(/^(\d\d\d) (.*)$/).captures # regex courtesy of ASE
      raise DNDUnknownError unless code == res_code
      res_data
    end

    def get_response( fmt, *args )
      @socket.writeline sprintf(fmt, *args)
      recv_response()
    end

    def recv_response
      @socket.readline
    end

    def check_response( res )
      return res if /\A2|\A1/ === res
      err = case res
            when /\A501/  then DNDBadFieldName
            when /\A520/  then DNDUserNotFound
            when /\A521/  then DNDFieldAccessDenied
            when /\A523/  then DNDUserNameTooShort
            else DNDUnknownError
            end
      raise err, res
    end

    def critical( &block )
      return '200 dummy reply code' if @error_occured
      begin
        return yield()
      rescue Exception
        @error_occured = true
        raise
      end
    end

  end # class DND

  # Special Shortcut wrapper classes...
  # The following two classes, which are taken from a previous DND module written by Ashley A. Thomas
  # are included here to make the interface of a DND session a little easier. While there are more than
  # two active DND servers on the Internet, the most common ones to be used by this module are:
  #
  # Main Dartmouth DND: host => dnd.dartmouth.edu
  # Dartmouth Alumni DND: host => dnd.dartmouth.org
  #
  # Similar to the generic DND class, you can pass in a pre-populated set of fields and wrap your
  # lookup calls in a block construct that ensures closure of the DND session upon exit.
  # 
  class DartmouthDND < DND
    def DartmouthDND.start(fields = [], &block) # :yield: dnd
      DND.start('dnd.dartmouth.edu', nil, fields, &block)
    end
  end
  class AlumniDND < DND
    def AlumniDND.start(fields = [], &block) # :yield: dnd
      DND.start('dnd.dartmouth.org', nil, fields, &block)
    end
  end

end # module Net

# This is a generic wrapper class for a DND user's profile.
# Part of the inspiration for this class comes from the way an ActiveRecord
# class is mapped to a database table row.
# In nearly all cases, instances of this class will be generated through a call
# into the Net::DND class, described above.
#
class DNDProfile

  def initialize( fields, data )
    @profile = {}
    raise IOError, 'fields and data must match' unless fields.length == data.length
    fields.each_with_index do |f, i| # updated from previous loop in 0.3, thanks to ASE
      @profile[f] = data[i]
    end
  end

  attr_reader :profile # added in 0.3 to handle profile fields with reserved names, i.e. "class"

  def inspect
    "#<#{self.class} profile=#{@profile.inspect}"
  end

  # Using method_missing, we provide a easy way to access the profile fields. Profiles are
  # strictly read-only, so we simply need to return the data.
  # This function also allows the pogrammer to ask dnd.nickname? and get back a true or false,
  # this is analogous to dnd.repond_to?("nickname")
  def method_missing(method_id)
    method_name = method_id.to_s
    if @profile.include?(method_name)
      @profile[method_name]
    elsif /\?$/ === method_name
      @profile.include?(method_name.chop("?"))
    else
      raise IOError, "Method #{method_id} does not exist in this DND Profile"
    end
  end
end # Class DNDProfile

