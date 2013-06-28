

class EasyriderConnection < Connection

    def initialize( args={} )

        super( args )

        @conn ||= EasyRider.new()

    end

    #our info methods
    def html()
        @conn.html
    end

    def url()
        @conn.url
    end

    def uri()
        @conn.uri
    end

    #our FetchMethods
    def get( url, headers={} )
        @conn.get( url )
    end

    def search_string( how, what, match_type )
        case
            when ( match_type == :broad and how != :xpath )
                Regexp.new( what )
        else
            what
        end
    end

    #our finder methods
    def find( method=nil, how=nil, what=nil, match_type=:broad )

        method ||= :elements

        #1.  method     -- should be div / span / input etc.. etc..
        #                  If no method specified we use elements
        #2.  how        -- should be :xpath / :id / :class etc.. etc..
        #3.  what       -- should be string
        #4.  match_type -- we convert string to regexp ONLY if we using
        #                  broad match and what is_a?(String)

        # ON Find Finished
        # 1.  Check to see if result responds_to to_a?
        # 2.  Return nil if is an array and array.empty?
        # 3.  Make sure all elements exist?
        # 4.  if array return first element.

        #first setup our find string

        srch_string = search_string( how, what, match_type )
        result      = @conn.send( method, how, srch_string )

        result = result.respond_to?( :to_a ) ? result.to_a : [ result ]
        result.delete_if{ |ele| !ele.exists? }
        result.empty? ? nil : result.first

    end



end
