
module Net ; module DND; module Protocol
  
  # The Field class is another wrapper class for the lookup command. Unless you are simply
  # performing a lookup to verify that there's at least one name match, you will be passing
  # one or more fields to the command, which will determine the data that's returned back,
  # once a successful match has been found.
  #
  # This class comes into play, because when the DND.start method is used, you pass in a list
  # of fields that you want to have returned. That list is first verified against the host
  # DND server's known list of fields, through use of the protocol's FIELDS command. When sent
  # with a list of fields, the server responds back with each fields read and write permissions.
  # This data, along with the fields name is captured and stored in instances of this class.
  
  class Field
    
    attr_reader :name, :writeable, :readable
    
    VALID_ACCESS_OPTIONS = ['A', 'U', 'N', 'T']
    
    def initialize(name, writeable, readable)
      @name = name.to_s
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
    
    def to_sym
      @name.to_sym
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
  
end ; end ; end

