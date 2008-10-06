module Net
  module DND

    # This is a container class for the User Specifier portion of the DND protocol lookup command.
    # Something like this isn't expressly needed, but because there are 3 types of specifier,
    # based around 4 different patterns of specifier, which leads to three slightly different
    # types of output, it seemed like a class was the best way to abstract those determinations.

    # Once a string specifier is passed into the constructer method, it's stored and then
    # matched against one of several patterns to determine it's type. This type is then used
    # to choose the output format of the specifier, when the instantiated class object is
    # coerced back to a string.

    class UserSpec

      attr_reader :type

      # Construct our specifier object and set its type attribute.

      def initialize(specifier)
        @spec = specifier.to_s
        @type = case @spec.downcase
          when /^\d+$/
            :uid
          when /^z\d+$/
            :did
          when /^\d+[a-z]\d*$/
            :did
          else
            :name
          end
      end

      # Output the correct 'string' format for our specifier. The :uid and :did types have
      # special characters prepended to their value, so that they are correctly formatted
      # for use in a DND connection/protocol lookup command.

      def to_s
        case @type
        when :uid
          "##{@spec}"
        when :did
          "#*#{@spec}"
        else
          @spec
        end
      end

      # Inspection string for the specifier object.

      def inspect
        "#<#{self.class} specifier=\"#{@spec}\" type=:#{@type}>"
      end
    end
  end
end
