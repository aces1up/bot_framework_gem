



class RawPost < Action

    SplitDelimeter = '##777##'

    include HeaderParser
    include PostBodyParser

    attr_accessor :headers, :post_body, :packet_filename, :method, :url, :content_type, :encode_mode
    attr_accessor :test_proxy

    def init()
        @url              = nil
        @method           = nil
        @content_type     = nil
        @encode_mode      = nil      #<--- this is only typically used on direct requests.
        @headers          = nil
        @post_body        = nil
        @packet_filename  = nil

        @test_proxy       = nil
    end

    def validate_filename()
        if !File.exists?( @packet_filename )
            raise ActionError, "Packet: #{@packet_filename} Cannot be loaded! Does Not Exists!"
        end
    end

    def init_post_data()
        #this will initialize our headers and post_body
        case
            when @packet_filename

                @packet_filename = "#{PacketDirectory}#{@packet_filename}"
                validate_filename()
                packet_loader = PacketLoader.new( @packet_filename )
                
                @headers       = packet_loader.headers           if !@headers
                @post_body     = packet_loader.body              if !@post_body
                @method        = packet_loader.method            if !@method
                @url           = packet_loader.url               if !@url
                @content_type  = packet_loader.content_type      if !@content_type
        end
    end
    
    def parse_url()
        @url = solve_tag( @url ) 
    end

    def set_test_proxy()
        set_proxy( @test_proxy ) if @test_proxy
    end

    def submit()

        info("Submitting Raw Request -- [Method: #{@method.to_s.upcase}] -- [URl: #{@url}]")

        set_test_proxy()

        case @method
          when :get   ;   get( @url, @headers )
          when :post  ;  post( @url, @post_body, @headers )
          when :put   ;   put( @url, @post_body, @headers )
        end
    end

    def run()
        init_post_data()
        parse_headers()
        parse_post_body() if !@post_body.empty?
        parse_url()       #<---- solves any tags found in our @url
        submit()
    end

end
