
class Connection

    include LogHandler
    include Enviornment
    include ArgsHelper
    include ElementWrapper

    attr_accessor :use_local_proxy

    def initialize( args={} )

        @conn            = nil      #<--- our connection object
        @use_local_proxy = false
        @proxy           = nil

        load_object_args( args )

    end

    def conn_method_implemented?( method )
        @conn.respond_to?( method )
    end

    def report_warning( method )
        #report a warning if we are running a method
        #on a non implmented botter method directly on the connection
        warn("Running Non Implmented Bot FrameWork Connection Method: #{method.inspect}")
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
        raise FunctionNotImplemented
    end

    def convert_proxy( proxy )
        # converts our proxy, if its a hash, or a string or is local
        # we fix it up and return it as either :local or a hash
        case
            when  @use_local_proxy                            ;  :local
            when  ( proxy.is_a?(Symbol) and proxy == :local ) ;  :local

            when  proxy.is_a?(String)
                  #convert the proxy string to hash here
                  proxy.split(':').to_h( [:ip, :port, :user, :pass] )
        else
            proxy #<---- this should be hash so just return it
        end
    end

    def get_proxy()
        #helper for getting proxy from cache
        ProxyCache.instance.get_proxy
    end

    def set_proxy( proxy )
        #actually sets the proxy on the connection
        raise FunctionNotImplemented
    end

    def switch_proxy()
        #will attempt to switch the proxy of the current connection handle here
        #by using the ProxyCache, and then calling the set Proxy Method
        #on the connection

        #this class does not need to be subclassed by lower connection handlers.
        proxy = get_proxy()
  
        #set a shared var so our gui can access it
        #proxy here would be a symbol if we are using :local
        #for proxy
        proxy_str = proxy.is_a?(Symbol) ? proxy : "#{proxy[:ip]}:#{proxy[:port]}"
        add( { :proxy => proxy_str }, :site, true )

        set_proxy( proxy )
    end

    def fetch_form( match_type, arg )
        #fetch a specific form on the page
        #fetch_type could be the following
        #  :max_fields
        #  :min_fields
        #  :with_action
        #  :with_index
        raise FunctionNotImplemented
    end

    def forms()
        #returns all forms on the page
        raise FunctionNotImplemented
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
        raise FunctionNotImplemented
    end

    def load_cookies(for_uri, cookies)
        #loads cookies into connection with the cookie array hash cookies
        #and using the for_uri
        raise FunctionNotImplemented
    end


    #image handling
    def image_urls()
        raise FunctionNotImplemented
    end

    def image_exists?( url )
        raise FunctionNotImplemented
    end

    def find_image_url( url, match_type=:broad )
        #searches through all image_urls and returns the
        #url that matches the one we sent. Other wise returns false
        raise FunctionNotImplemented
    end

    #find / search elements
    def find( method, how=nil, what=nil, match_type=:broad )
        raise FunctionNotImplemented
    end

    #Navigation and Info

    def cur_url()
        #returns the current url
        raise FunctionNotImplemented
    end

    def cur_uri()
        #returns the current uri of loaded page
        raise FunctionNotImplemented
    end

    def html()
        #returns current html of page
        raise FunctionNotImplemented
    end

    def save_html(filename)
        #check to see if filename has a directory with it.
        #if not set it to working directory / html
        if !is_full_path?( filename )
            filename = "#{HTMLDirectory}#{filename}"
        end
        write_data_to_file( filename, html )
    end

    def get( url, headers={} )
        raise FunctionNotImplemented
    end

    def post( url, body, headers )
        raise FunctionNotImplemented
    end

    def put( url, body, headers )
        raise FunctionNotImplemented
    end

    def submit( form )
        raise FunctionNotImplemented
    end

    def current_connection_type()
        #return current connection type as string
        self.class.to_s.gsub('Connection','')
    end

    def all_connection_info()
        #calls all our connection info and builds a hash

        info = ConnectionInfoHashMethods.map{ |conn_method|
            val = nil            
            val = send( conn_method ) if respond_to?( conn_method )
            { conn_method => val }
        }

        info.reduce Hash.new, :merge
    end

    def method_missing( method, *args)

        if @conn.respond_to?( method )
            warn("Non Implemented Connection Running Method: #{method.inspect} -- Obj: #{self.obj_info}")
            wrap( @conn.send( method, *args ), method )
        else
            super
        end
    end

end
