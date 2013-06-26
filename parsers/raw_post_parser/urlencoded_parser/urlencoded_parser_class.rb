
class URLEncodePart

    include TagSolverHelper

    attr_reader :part_str

    def initialize( part )
        #this passes in a urlencode param
        # ex:  userid=dude

        #encode modes are :cgi_encode, :url_encode
        # :url_encode uses %20 chars on spaces   <--- using require 'addressable/uri' ; Addressable::URI.escape
        # :cgi_encode uses +   chars for spaces  <--- using CGI::escape
        # on default we use :cgi_encode

        @part_str      = part

        @field_encode_mode  = :cgi_encode

        @value_encode_mode  = :cgi_encode     #<--- determines if we CGI Escape this
                                              #<--- param value or not
        @field = nil
        @value = nil

        init_encode_vars()

    end

    def encoded?( val )
        val.count('%') >= 2
    end
    
    def encode_mode( val )
        case
            when  ( encoded?( val ) and val.include?('+') )    ;  :cgi_encode
            when  ( encoded?( val ) and val.include?('%20') )  ;  :url_encode
        else
            :cgi_encode  #<--- set cgi encode on default
        end
        
    end

    def param_to_s( param )
        #this will convert the param pair to a
        #string base used for rendering it readable
        parsed = CGI::parse(param)
        param = parsed.keys.first
        value = parsed[param][0]

        value.strip!

        [ param, value ]
    end


    def init_encode_vars()
        #@field, @value = @part_str.split('=', 2)
        @field, @value = param_to_s( @part_str )

        @field_encode_mode = encode_mode( @field )
        @value_encode_mode = encode_mode( @value )
    end

    def to_encoded( val, encode_mode )

        solved_tag = solve_tag( val )

        case encode_mode
            when  :cgi_encode  ;  CGI::escape( solved_tag )
            when  :url_encode  ;  Addressable::URI.escape( solved_tag )
        end
    end

    def to_s()
        #drops a string representation that we can use to build the
        #query for this param
        "#{to_encoded( @field, @field_encode_mode )}=#{to_encoded( @value, @value_encode_mode )}"
    end
end

class UrlEncoderParser

    def initialize( raw_post_data )
        @raw_post_data = raw_post_data
        @param_objs    = []

        init_param_objs()
    end

    def init_param_objs()
        #this will split our string into param objects
        @param_objs = @raw_post_data.split('&').map{ |param_str| URLEncodePart.new(param_str) }
    end

    def to_s()
        @param_objs.map{ |param| param.to_s }.join('&')
    end

end
