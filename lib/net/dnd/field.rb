
module Net ; module DND
  
  class Field
    
    attr_reader :name
    
    VALID_ACCESS_OPTIONS = ['A', 'U', 'N', 'T']
    
    def initialize(name, writeable, readable)
      @name = name
      store_access_value(:writeable, writeable)
      store_access_value(:readable, readable)
    end
    
    def self.from_field_line(line)
      args = line.split
      raise "Invalid Field Line" unless args.length == 3
      new(args[0], args[1], args[2])
    end
    
    def inspect
      "#<#{self.class} name=\'#{@name}\' writeable=\'#{@writeable}\' readable=\'#{@readable}\'>"
    end
    
    def to_s
      @name
    end
    
    def read_all?
      @readable == 'A'
    end
    
    private
    
    def store_access_value(read_write, value)
      raise "Invalid Access Value" unless VALID_ACCESS_OPTIONS.include?(value)
      instance_variable_set("@#{read_write}".to_sym, value)
    end
    
  end
  
end ; end

