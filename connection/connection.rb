
class Connection

    include LogHandler
    include Enviornment
    include ArgsHelper


    attr_accessor :use_local_proxy

    def initialize( args={} )

        @conn            = nil      #<--- our connection object
        @use_local_proxy = false
        @proxy           = nil

        load_object_args(args)
    end

    def using_local_proxy?()
        return true if @use_local_proxy
        ( @proxy.is_a?(Symbol) and @proxy == :local )
    end

    def is_dead_site?( error_object )
        # determines if site is unavailable ex.. the error we are processing
        # has a 404 / 500 error or other type of error that says the site is unavailable.
        # if we return true on this, the underlying code will attempt to do a proxy
        # switch
        raise NotImplementedError
    end

    def get_proxy()
        #helper for getting proxy from cache
        ProxyCache.instance.get_proxy
    end

    def set_proxy( proxy )
        #actually sets the proxy on the connection
        raise NotImplementedError
    end

    def switch_proxy()
        #will attempt to switch the proxy of the current connection handle here
        #by using the ProxyCache, and then calling the set Proxy Method
        #on the connection

        #this class does not need to be subclassed by lower connection handlers.
        proxy = get_proxy()
  
        #set a shared var so our gui can access it
        self[:proxy] = proxy.is_a?(Symbol) ? proxy : "#{proxy[:ip]}:#{proxy[:port]}"

        set_proxy( proxy )
    end

    def fetch_form( match_type, arg )
        #fetch a specific form on the page
        #fetch_type could be the following
        #  :max_fields
        #  :min_fields
        #  :with_action
        #  :with_index
        raise NotImplementedError
    end

    def forms()
        #returns all forms on the page
        raise NotImplementedError
    end


    def teardown()
        #handles any tearing down of the connection here
        #this should be subclassed to unsure connection is closed
        #down gracefully.
    end

    #cookie Handling
    def cookies()
        #returns an array of hash of cookies so we can easily load it
        #into whatever connection that might need to transfer cookies
        raise NotImplementedError
    end

    def load_cookies(for_uri, cookies)
        #loads cookies into connection with the cookie array hash cookies
        #and using the for_uri
        raise NotImplementedError
    end


    #image handling
    def image_urls()
        raise NotImplementedError
    end

    def image_exists?( url )
        raise NotImplementedError
    end

    def find_image_url( url, match_type=:broad )
        #searches through all image_urls and returns the
        #url that matches the one we sent. Other wise returns false
        raise NotImplementedError
    end

    #find / search elements
    def find( method, how=nil, what=nil, match_type=:broad )
        raise NotImplementedError
    end

    #Navigation and Info

    def cur_url()
        #returns the current url
        raise NotImplementedError
    end

    def cur_uri()
        #returns the current uri of loaded page
        raise NotImplementedError
    end

    def html()
        #returns current html of page
        raise NotImplementedError
    end

    def save_html(filename)
        #check to see if filename has a directory with it.
        #if not set it to working directory / html
        if !is_full_path?( filename )
            filename = "#{HTMLDirectory}#{filename}"
        end
        write_data_to_file( filename, html )
    end

    def get(url)
        raise NotImplementedError
    end

    def post( url, body, headers )
        raise NotImplementedError
    end

    def put( url, body, headers )
        raise NotImplementedError
    end

    def submit( form )
        raise NotImplementedError
    end

end
