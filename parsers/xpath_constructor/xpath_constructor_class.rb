

class XpathConstructor

    include ArgsHelper

    attr_accessor :method, :how, :what, :exact

    def initialize( args={} )  #<--- ( how, what, method=nil, exact=false )

        @method = '*'
        @how    = nil
        @what   = nil
        @exact  = false

        load_object_args( args )

        @method ||= '*'

    end

    def escape_single_quotes_for_xpath( string )
        if string =~ /'/
           #string.gsub( /'/, "" ) # horribly, this is how you escape single quotes in XPath.
           "\"#{string}\""
        else
           "'#{string}'"
        end
    end

    def build_attr()

        x_attr = @how.to_s
        x_what = escape_single_quotes_for_xpath( @what.to_s )

        if exact   #<---- our exact match regexes.

            case @how.to_sym

                when :text
                     "text()=#{x_what}"
                else
                     "@#{x_attr}=#{x_what}"
            end

        else       #<--- Not Exact Match What happens most of the time.

            case @how.to_sym

                when :text
                    "text()[contains(.,#{x_what})]"
                else
                    "contains(@#{x_attr},#{x_what})"
            end

        end

    end

    def build_query()
        "//#{@method}[#{build_attr}]"
    end


end

