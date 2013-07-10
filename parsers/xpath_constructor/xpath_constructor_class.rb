

class XpathConstructor

    include ArgsLoader

    attr_accessor :method, :how, :what, :exact

    def initialize( args={} )  #<--- ( how, what, method=nil, exact=false )

        @method = '*'
        @how    = nil
        @what   = nil
        @exact  = false


        load_object_args( args )

        @method ||= '*'

        @x_array = [] #<--- array of key value pairs of how and what search criteria
                      #<--- ex:  @how  = "id&class"
                      #          @what = "password&grey_button"
                      #     Result : [ :how => "id", :what => "password", :how => "grey_button" ]

        init_x_array
        #build_query
    end

    def escape_single_quotes_for_xpath(string)
        if string =~ /'/
           #string.gsub( /'/, "" ) # horribly, this is how you escape single quotes in XPath.
           "\"#{string}\""
        else
           "'#{string}'"
        end
    end

    def build_attr(how, what, exact=false)

        x_attr = how.to_s
        x_what = escape_single_quotes_for_xpath( what.to_s )

        if exact   #<---- our exact match regexes.

            case how.to_sym

                when :text
                     "text()=#{x_what}"
                else
                     "@#{x_attr}=#{x_what}"
            end

        else       #<--- Not Exact Match What happens most of the time.

            case how.to_sym

                when :text
                    "text()[contains(.,#{x_what})]"
                else
                    "contains(@#{x_attr},#{x_what})"
            end

        end

    end

    def init_x_array
        @x_array = ( @how.to_s.split('&').zip @what.to_s.split('&') ).flatten
    end

    def attr_query()
        attr_string = []
        @x_array.each_slice(2) do |how, what|

              if what.include?('|')
                  #we have multiple searches we want to perform so
                  #split them and create an attribute search for each of them.
                  sub_search = what.split('|').map{ |sub_what| build_attr(how, sub_what, @exact) }
                  attr_string << sub_search.join(' or ')
              else
                  attr_string << build_attr(how, what, @exact)
              end

        end
        attr_string.join(' and ')
    end

    def build_query()
        "//#{@method}[#{attr_query}]"
    end


end
