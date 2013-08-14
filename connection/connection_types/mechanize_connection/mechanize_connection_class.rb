

class MechanizeConnection < Connection

    def initialize( args={} )

        super( args )

        @conn             ||= Mechanize.new
	      @conn.verify_mode  = OpenSSL::SSL::VERIFY_NONE
        @conn.keep_alive   = false     
        @conn.open_timeout = 10
        @conn.read_timeout = 10
        @conn.max_history  = 1

        #setup our initial proxy here



        UseFiddlerProxy ? set_proxy( '127.0.0.1:8888' ) : switch_proxy
        set_user_agent
    end
    
    def is_response_code_dead_site?(response_code)
        [400..407, 500..505].any?{|range| range.include?( response_code.to_i ) }
    end

    def is_dead_site?( error_object )
        case error_object.class.to_s
            when 'Mechanize::ResponseCodeError' ; is_response_code_dead_site?( error_object.response_code )
            when 'SocketError'                  ; error_object.message.downcase.include?('name or service not known')
        else
            #we were not able to determine if this was a dead site using the above
            #methods so just return false as we are not sure.
            false
        end
    end

    def set_proxy( proxy )

        @proxy = convert_proxy( proxy )
              
        case 
            # check if we are using local ip message
            when using_local_proxy? ; info( "Using LOCAL IP.." )
        else
            info("Setting Mechanize Proxy to : [ #{@proxy[:ip]}:#{@proxy[:port]} ]")
            @conn.set_proxy( @proxy[:ip], @proxy[:port], @proxy[:user], @proxy[:pass] )
        end
      
        @proxy   #<---- return it here just so other function might use the return.
    end

    def set_user_agent()
        agent_str = 'User-Agent: Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Win64; x64; Trident/4.0; .NET CLR 2.0.50727; SLCC2; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0)'
        @conn.user_agent = agent_str
    end

    def cookies()
        cookie_vars = [
         :name, :value, :version, :domain, :path, :secure, :comment, :max_age,
         :session, :created_at, :accessed_at
        ]
        @conn.cookies.map{ |cookie_obj| Hash[ *cookie_vars.map{|cookie_var| [ cookie_var, cookie_obj.send(cookie_var) ] }.flatten ] }
    end

    def load_cookies(for_uri, cookies)

        cookies.each do |cookie_data|
            cookie_data[:for_domain] = true
            mech_cookie = Mechanize::Cookie.new( cookie_data )
            @conn.cookie_jar.add( for_uri, mech_cookie )
        end

        cookies.length  #<--- return number of cookies for reporting purposes
    end

    def html()
        return "" if @conn.page.nil?
        @conn.page.body.to_s
    end

    def cur_url()
        return nil if @conn.page.nil?
        @conn.page.uri.to_s
    end

    def cur_uri()
        return nil if @conn.page.nil?
        @conn.page.uri
    end


    #our Fetch Methods
    def get( url, headers={} )
        info "[Fetching] -- #{url}"
        if headers.empty?
            SwitchUserAgent ? @conn.get( url, [], nil, { 'User-Agent' => UserAgents.sample } ) : @conn.get( url )
        else
            @conn.get( url, [], nil, headers )
        end
    end

    def post( url, body, headers={} )
        @conn.post( url, body, headers )
    end

    def put( url, body, headers )
        @conn.put( url, body, headers )
    end

    def submit( form )
        @conn.submit(form)
    end

    def fetch_form( match_type=:max_fields, arg=nil )
        #fetch_type could be the following
        #  :max_fields
        #  :min_fields
        #  :with_action
        #  :with_index
        case match_type.to_sym

            when :max_fields   ; forms.max_by{ |form| form.all_fields.length }
            when :min_fields   ; forms.min_by{ |form| form.all_fields.length }
            when :action       ; find( :form, :action, arg )
            when :index        ; find( :form, :index,  arg )

        end
    end

    def forms()
        #@conn.page.forms.map{|form| wrap_element( form ) }
        @conn.page.forms
    end

    def image_urls()
        return [] if !@conn.page
        @conn.page.image_urls.map{ |image| image.class == URI::HTTP ? image.to_s : image }
    end

    def find_image_url( url, match_type=:broad )

        #searches through all image_urls and returns the
        #url that matches the one we sent. Other wise returns false
        case match_type
            when :exact ; image_urls.find{ |image_url| image_url == url }
        else
            image_urls.find{ |image_url| image_url =~ Regexp.new(url) }
        end
    end

    def image_exists?( url, match_type=:broad )
            
        found = find( :image, :url, url, match_type  )
        found ? true : false
 
    end
  
    def find( method, how=nil, what=nil, match_type=:broad )

        return nil if @conn.page.nil?

        found_ele = nil

        case how
            when :index
                find_method = "#{method.to_s}s".to_sym
                return nil if !@conn.page.respond_to?( find_method )

                found_ele = @conn.page.send( find_method )[what]
        else
            find_method = "#{method.to_s}_with".to_sym
            return nil if !@conn.page.respond_to?( find_method )
        
            #only convert what to a regex if we are doing a broad match.
            what = Regexp.new(what) if ( what.is_a?(String) and match_type == :broad )
            found_ele = @conn.page.send( find_method, how.to_sym => what)
        end

        found_ele 
    end

end
