
module Net ; module DND
  
  module CommandIo
    
    def self.extended(object)
      object.__send__(:initialize_stream)
    end
    
    attr_reader :code, :response
    
    def get_fields(fields=[])
      cmd = 'fields'
      fields = fields.join(" ")
      cmd << " #{fields}" unless fields.empty?
      puts cmd
      @code, @response = next_line('102')
      ary = []
      @response.to_i.times do
        c, r = next_line('120')
        ary << r
      end
      @code, @response = next_line
      return ary
    end
    
    protected
      
      def initialize_stream
        @code, @response = next_line('220')
      end
      
      def next_line(good='200')
        c, r = gets.chomp.match(/(\d\d\d) (.+)/).captures
        raise r unless c == good
        return c, r
      end
      
  end
  
end ; end
