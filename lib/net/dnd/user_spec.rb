
module Net ; module DND
  
  class UserSpec

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
    
    def inspect
      "#<#{self.class} specifier=\'#{@spec}\' type=:#{@type}>"
    end
    
  end
  
end ; end
