

class DeathbycaptchaSolver < CaptchaService

    include DeathByCaptchaValidator

    RetryErrors = [ 'internal+server+error', 'under maintenance', '<html>' ]

    def init()
        @captcha_id = nil
        @correct = nil
        @cap_solved = nil
        @status = 0
        @err = nil  #<--- set to our error if we have one.
    end

    def parse_result(result)
        #status=0&is_banned=0&balance=623.971&rate=0.139&user=69892
        #returns a hash with each key / value of all pairs
        Hash[*result.split(/=|&/)]
    end

    def is_retry_error?()
        res = html
        RetryErrors.any?{|err| res.include?( err )  }
    end
    
    def set_captcha_result_vars()
        #this will use html to attempt to parse
        #and load the captcha result vars into our instance vars
        if is_retry_error?
            #if we have retry error set our @err as server error and then it will be caught later
            @err = 'DeathByCaptcha had Error while Polling for Captcha Solution!'
            return
        else
            res_hash = parse_result( html )
        end
        
        #info("Result Hash : #{res_hash.inspect}")

        @err = nil
        
        @captcha_id = res_hash['captcha']
        @err = 'Unable to Determine Captcha ID from DeathByCaptcha Service' if !@captcha_id

        @correct = res_hash['is_correct'] == 0 ? false : true
        @err = 'DeathByCaptcha Reports Invalid Captcha Image!' if !@correct

        if res_hash['text']
            @cap_solved = res_hash['text'].empty? ? nil : CGI::unescape( res_hash['text'] )
        end
         
        @status = res_hash['status']

        #info "Saved #{@captcha_id} -- #{@correct.inspect} -- #{@cap_solved.inspect} -- #{@status.inspect}"
    end

    def handle_retry()   
        info("Polling DeathByCaptcha Server for Captcha Solve -- [ Retry: #{@retry} / 10 ] ")
        get("http://api.dbcapi.me/api/captcha/#{@captcha_id}")
    end

    def poll_for_answer()

        #next line will setup the @cap_solved if we solved the captcha
        #@err returns if there is problem with data ex.. we need
        #to kill solving as we can't solve due to @err

        set_captcha_result_vars()
        @retry = 0

        while !@cap_solved and !@err and @retry < 10
            handle_retry()
            set_captcha_result_vars()
            sleep(5)
            @retry += 1
        end


        #return the correct value based on what we found from
        #the poll retry code
        case
            when @cap_solved  ;  @cap_solved
            when @err         ;  raise CaptchaError, @err
        else
            #we were unable to solve captcha here
            raise CaptchaError, 'Unable to Solve Captcha using DeathByCaptcha Service'
        end
              
    end

    def handle_response()
        #this will handle the response..
        info("DeathByCaptcha Response: #{html.inspect}")

        if is_retry_error?()
            solve
        else
            info 'Polling DeathByCaptcha Server for Captcha Solve'
            poll_for_answer
        end
    end

    def init_server()
        servers = ['http://api.dbcapi.me/api/captcha']

        @server_url = servers.sample
        @server_url
    end

    def init_headers(post_data=nil)
        boundary = post_data ? post_data.boundary : @post_data.boundary

        @headers = {}
        @headers['Host'] = Addressable::URI.parse(@server_url).host
        @headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:17.0) Gecko/20100101 Firefox/17.0'
        @headers['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
        @headers['Accept-Language'] = 'en-US,en;q=0.5'
        @headers['Accept-Encoding'] = 'gzip, deflate'
        @headers['Content-Type'] = "multipart/form-data; boundary=#{boundary}"
        @headers
    end

     def init_post_data()
        image_part = Part.new(:name => 'captchafile', :body => @image_data, :filename => 'captcha.jpg', :content_type => 'image/jpeg')

        username = "#{GlobalSettings.instance.get_var(:deathbycaptcha_username)}\r\n"
        username_part = Part.new(:name => :username, :body => username)

        password = "#{GlobalSettings.instance.get_var(:deathbycaptcha_password)}\r\n"
        password_part = Part.new(:name => :password, :body => password)

        @post_data = MultipartBody.new( [ username_part, password_part, image_part ] )
        @post_data.boundary = '---------------------------9374110204596'
        @post_data
    end

    def solve()
        info("[DeathByCaptcha Service] -- Solving Captcha")

        if max_retries_met?()

            error = @result[:error_msg] ? @result[:error_msg] : "Max Retries Met for DeathByCaptcha Server"
            raise CaptchaError, error

        else
            init_post_data()
            init_server()
            init_headers()

            super()
        end

    end


end
