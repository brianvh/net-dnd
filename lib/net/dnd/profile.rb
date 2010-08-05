$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__))
require 'errors'

module Net
  module DND

    autoload :Expires, 'expires'

    # Container class for a single DND Profile. Takes the current fields set in the Session, along with
    # the returned items from a lookup command and builds a 'profile' Hash. The class then provides
    # dynamic accessor methods for each of the fields, as well as a [] accessor method for accessing
    # fields whose name is a Ruby reserved word, i.e. class.
    class Profile

      # The profile constructor method. Takes 2 array arguments: fields and items. From these
      # it creates a Hash object that is the internal represenation of the profile.

      def initialize(fields, items)
        @profile = Hash[*fields.zip(items).flatten]

        if @profile.has_key?(:expires)
          self.extend Net::DND::Expires
        end
      end

      # Inspection string for instances of the class

      def inspect
        attrib_inspect = @profile.inject("") { |s, pair| k,v = pair; s << "#{k}=\"#{v}\", " }
        "<#{self.class} length=#{length}, #{attrib_inspect.rstrip.chomp(',')}>"
      end

      # Length of the class instance, basically the number of fields/items. Only really used
      # by the inspect method.

      def length
        @profile.length
      end

      # Generic Hash-style accessor method. Provides access to fields in the profile hash when
      # the name of the field is a reserved word in Ruby. Allows for field names supplied as
      # either Strings or Symbols.

      def [](field)
        return_field(field)
      end

      private

      # Handles all dynamic accessor methods for the Profile instance. This is based on the
      # field accessor methods from Rails ActiveRecord. Fields can be directly accessed on
      # the Profile object, either for purposes of returning their value or, if the field name
      # is requested with a '?' on the end, a true/false is returned based on the existence of
      # the named field in Profile instance.

      def method_missing(method_id)
        attrib_name = method_id.to_s
        return @profile.has_key?(attrib_name.chop.to_sym) if attrib_name[-1, 1] == '?'
        return_field(method_id)
      end

      # Private method, used by the [] method and the dynamic accessors. It will return the value
      # of the named field, or it will raise a FieldNotFound error if the field isn't part of the
      # current Profile.

      def return_field(field)
        field = field.to_sym
        return @profile[field] if @profile.has_key?(field)
        raise FieldNotFound, "Field #{field} not found."
      end

    end
  end
end
