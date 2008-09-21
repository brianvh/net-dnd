
module Net ; module DND

  class Profile

    def initialize(fields, items)
      @attributes = Hash[*fields.zip(items).flatten]
    end

    def inspect
      attrib_inspect = @attributes.inject("") { |s, pair| k,v = pair; s << "#{k} = \"#{v}\", " }
      "<#{self.class} length = #{length}, #{attrib_inspect.rstrip.chomp(',')}>"
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
      raise "Field #{field} does not exist in this Profile"
    end

  end

end; end
