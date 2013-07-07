

class EasyriderConnection < Connection

    def initialize( args={} )

        super( args )

        switch_proxy()      #<--- this will set @proxy
        # Merge in our proxy for initialization if we are not using local proxy
        args.merge!( { :proxy => @proxy } ) if !using_local_proxy?

        @conn ||= EasyRider.new( args )

    end

    def set_proxy( proxy )
        @proxy = convert_proxy( proxy )
        if using_local_proxy?
            info( "Using LOCAL IP.." )
        else
            info("Setting EasyRider Proxy to : [ #{@proxy[:ip]}:#{@proxy[:port]} ]")
        end
    end


    #our info methods
    def html()
        @conn.html
    end

    def cur_url()
        @conn.cur_url
    end

    def cur_uri()
        @conn.cur_uri
    end

    def cookies()
        [1,2,3,4,
         { :dude => { :four => [5,6,7] } },
        5]
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
