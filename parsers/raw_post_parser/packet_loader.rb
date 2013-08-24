
class PacketLoader

    attr_reader :headers, :body, :content_type, :method, :url

    def initialize( filename )

        @filename  = filename
        @text      = nil

        @headers   = nil
        @body      = nil
        @method    = nil
        @url       = nil

        @content_type = :direct

        load()
        split_text()    #<--- splits the text into lines and get the index
                        #<--- of seperator

        store_data()    #<--- sets our headers and body from @lines

        set_body_type() #<--- detects if our body is multi-part form data
                        #<--- direct_data or url_encoded data

        set_method_and_url()    #<--- sets method of this request.. ex: get, put, post

    end

    def load()
        @text = IO.read( @filename )
    end

    def split_text()
        @lines = @text.split("\n")
        @params_index = @lines.index{ |line| line.empty? }
    end

    def set_headers()
        @headers = @lines[0..@params_index-1]
    end

    def set_body()
        @body = @lines[@params_index+1..-1].join("\n")
    end

    def store_data()
        set_headers()
        set_body()
    end

    def get_header_hash()
        raw = @headers.map{ |header| header.split(':',2).map{|str| str.lstrip } }.flatten
        Hash[*raw]
    end

    def get_content_type( header_hash )

        header_types = header_hash.keys.map{|key| key.to_s.downcase }
        return false if !header_types.include?( 'content-type' )
        downcase_header_hash = header_hash.each_with_object({}) do |(k, v), h|
            h[k.downcase] = v
        end

        content_type = downcase_header_hash[ 'content-type' ]
        return false if content_type.nil? or content_type.empty?

        case
            when content_type.include?( 'urlencoded' )   ;   :urlencoded
            when content_type.include?( 'multipart' )    ;   :multipart
        else
            false
        end

    end

    def header_content_type()
        return nil if !@headers or @headers.empty?
        header_hash = get_header_hash()
        get_content_type( header_hash )
    end

    def set_body_type()

        return if !@body or @body.empty?

        header_type = header_content_type

        @content_type = case
                          #first check to see if we can detect content type from the
                          #headers
                          when header_type            ;  header_type

                          #ok if we get here we can't determine content type from
                          #headers so lets try and see if we can determine from body
                          #type
                          when @body =~ /-+\d+/       ;  :multipart
                          when @body.count('=') >= 3  ;  :urlencoded
                          when @body.count('&') >= 3  ;  :urlencoded
                     else
                          :direct
                     end
    end

    def header_is_method_line?( header )
        FetchMethods.any?{ |method| header.include?( method.to_s.upcase ) }
    end

    def set_method_and_url()

        method_header_index = @headers.index{ |header| FetchMethods  }
        raise RawPostError, "Packet Loader Cannot Determine Method Header Location!" if !method_header_index

        method_header = @headers.delete_at( method_header_index )

        #header_method = method_header[0..3].downcase
        @method = [ :get, :put, :post ].find{ |meth| method_header.downcase[0..3].include?( meth.to_s ) }

        @url = ( method_header =~ /(http.*)\s+HTTP/ ).nil? ? nil : $1
    end

end
