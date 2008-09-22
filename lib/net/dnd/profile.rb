folder_path = File.dirname(__FILE__)
require "#{folder_path}/errors"

module Net
  module DND

    # Container class for a single DND Profile. Takes the current fields set in the Session, along with
    # the returned items from a lookup command and builds an attributes Hash. The class then provides
    # dynamic accessor methods for each of the fields, as well as a [] accessor method for accessing
    # fields whose name is a Ruby reserved word, i.e. class.
    class Profile

      def initialize(fields, items)
        @attributes = Hash[*fields.zip(items).flatten]
      end

      def inspect
        attrib_inspect = @attributes.inject("") { |s, pair| k,v = pair; s << "#{k}=\"#{v}\", " }
        "<#{self.class} length=#{length}, #{attrib_inspect.rstrip.chomp(',')}>"
      end

      def length
        @attributes.length
      end

      def [](field)
        return_field(field)
      end

      private
    
      def method_missing(method_id)
        attrib_name = method_id.to_s
        return @attributes.has_key?(attrib_name.chop.to_sym) if attrib_name[-1, 1] == '?'
        return_field(method_id)
      end

      def return_field(field)
        field = field.to_sym
        return @attributes[field] if @attributes.has_key?(field)
        raise FieldNotFound, "Field #{field} does not found in this Profile"
      end

    end
  end
end
