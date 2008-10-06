folder_path = File.dirname(__FILE__)
require "#{folder_path}/connection"
require "#{folder_path}/profile"
require "#{folder_path}/field"
require "#{folder_path}/errors"

module Net
  module DND

    # This is the DND session object. It provides the high-level interface for performing
    # lookup-style searches against a given DND host. It manages the Connection object,
    # which is the low-level socket stuff, and sends back DND Profile objects, either singly or
    # an array, as the result of the find method.

    class Session

      attr_reader :fields, :connection

      # Constructor method. Only called directly by unit tests (specs). The start method
      # handles the setting up of a full DND session.

      def initialize(host)
        @connection = Connection.new(host)
        raise ConnectionError, connection.error unless connection.open?
      end

      # Starts a new DND session/connection. Called by the module-level start methods.

      def self.start(host, field_list=[])
        session = Session.new(host)
        session.set_fields(field_list)
        session
      end

      # Are we still open?

      def open?
        connection.open?
      end

      # Set the list of fields used by subsequent find commands. These fields are then passed
      # to the Profile.new method when one or more users are returned by the find command. This
      # method will raise a couple of error messages, that you might want to trap for:
      #
      # FieldNotFound is raised when a specified field is not found in the list of fields known
      #   by the currently connected to DND server.
      #
      # FieldAccessDenied is raised when a speficied field is one whose value is not world
      #   readable, meaning you need to be in an authenticated session to access it.
      #
      # You can manually send the set_fields command, if you happen to need to change the list of
      # fields returned by your find commands, after you've instantiated the session object.

      def set_fields(field_list=[])
        response = request(:fields, field_list)
        @fields = []
        raise FieldNotFound, response.error unless response.ok?
        response.items.each do |item|
          field = Field.from_field_line(item)
          if field.read_all? # only world readable fields are valid for DND Profiles
            @fields << field.to_sym
          else
            raise FieldAccessDenied, "#{field.to_s} is not world readable." unless field_list.empty?
          end
        end
      end

      # The find command is the real reason for the Net::DND libray. It provides the ability to
      # send a 'user specifier' to a connected DND server and then parse the returned data into
      # one or more Net::DND::Profile objects.
      #
      # You can send the find command in two flavors: the first, when you simply submit the look_for
      # argument will assume that you're expecting more than one user to match the look_for string.
      # Thus it will always return a array as its result. This array will contain zero, one or more
      # Profile objects.
      #
      # In it's second flavor, you are submitting a value for the 'one' argument. Normally, this
      # means you've sent a :one as the second argument to the call, but any non-false value will
      # work. When called in this manner, you're telling the Session that you only want a Profile
      # object if your 'look_for' returns a single match, otherwise the find will return nil. This
      # flavor is recommended when you are performing a find using a 'uid' or a 'dctsnum' value.

      def find(look_for, one=nil)
        response = request(:lookup, look_for.to_s, fields)
        if one
          return nil unless response.items.length == 1
          Profile.new(fields, response.items[0])
        else
          response.items.map { |item| Profile.new(fields, item) }
        end
      end

      # The manual session close command. You only call this method if you aren't using the block
      # version of the module 'start' command. If you use the block, it will automatically close
      # the session when the block exits.

      def close
        request(:quit, nil)
      end

      private

      # This method handles the sending of the raw protocol commands to the Connection object. It
      # will only send commands if the Session is still 'open'. It always returns the Response object
      # back from the result of calling into the Connection.

      def request(type, *args)
        raise ConnectionClosed, "Connection closed." unless open?
        response = connection.send(type, *args)
      end

    end
  end
end
