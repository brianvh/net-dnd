
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
      field = field.to_sym
      return @attributes[field] if @attributes.has_key?(field)
      raise "Field #{field} does not exist in this Profile"
    end

    private
    
    def method_missing(method_id)
      attrib_name = method_id.to_s
      if @attributes.has_key?(method_id)
        @attributes[method_id]
      elsif attrib_name[-1, 1] == '?'
        attrib_name = attrib_name.chop.to_sym
        @attributes.has_key?(attrib_name)
      else
        raise "Field #{method_id} does not exist in this Profile"
      end
    end

  end
  
end; end
