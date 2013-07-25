

class DecaptcherSolver < CaptchaService

    ErrorCodes = {
                  '0' => 'Response OK',
                  '-1' => 'general internal error',
                  '-2' => 'status is not correct',
                  '-3' => 'network data transfer error',
                  '-4' => 'text is not of an appropriate size',
                  '-5' => 'server\'s overloaded',
                  '-6' => 'not enough funds to complete the request',
                  '-7' => 'request timed out',
                  '-8' => 'provided parameters are not good for this function',
                  '-200' => 'unknown error',
                  '-201' => 'Returned data not correct'
                 }
    RetryErrors = ['-7', '-5']

    def is_retry_error?()
        RetryErrors.include? @result[:error_code]
    end

    def init() ; end

    def init_headers(post_data=nil)
        boundary = post_data ? post_data.boundary : @post_data.boundary

        @headers = {}
        @headers['Host'] = Addressable::URI.parse(@server_url).host
        @headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:10.0.1) Gecko/20100101 Firefox/10.0.1'
        @headers['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
        @headers['Accept-Language'] = 'en-us,en;q=0.5'
        @headers['Accept-Encoding'] = 'gzip, deflate'
        @headers['Content-Type'] = "multipart/form-data; boundary=#{boundary}"
        @headers
    end

    def init_server()
      servers = ['http://poster.de-captcher.com/',
                 'http://poster.de-captcher.info/'
                ]

      @server_url = servers.sample
      @server_url
    end

    def init_post_data()
        image_part = Part.new(:name => 'pict', :body => @image_data, :filename => 'captcha.jpg', :content_type => 'image/jpeg')

        @post_data = MultipartBody.new(
            :function => 'picture2',
            :username => @creds[:username],
            :password => @creds[:password],
            :pict_to => 0,
            :pict_type => 0
        )
        @post_data.parts.insert(3, image_part)
        @post_data = @post_data
        @post_data
    end

    def bad_result_code?(code)
        !ErrorCodes.keys.include?(code)
    end

    def handle_response()

        res_split = html.split('|')

        debug("Response Split: #{res_split.inspect} -- Length: #{res_split.length}")

        if res_split.length != 6 then
            #set up our error codes here
            if res_split.length == 1 then
                @result[:error_code] = res_split[0]
                #double check the result code here
                #is good.
                @result[:error_code] = '-201' if bad_result_code?( @result[:error_code] )
            else
                @result[:error_code] = '-201'
            end

        else
            #set up our results here
            @result[:error_code] = res_split[0]
            @result[:major_id] = res_split[1]
            @result[:minor_id] = res_split[2]
            @result[:captcha] = res_split[5]
        end
        @result[:error_msg] = ErrorCodes[@result[:error_code]]

        if @result[:error_code] == '0' then
            #we have a valid response, so lets assume the captcha was solved correct
            @result[:captcha]  #<--- return captcha to mediator
        else
            if is_retry_error?()
                solve()  #<--- run solve again to do a retry
            else
                #we have a decaptcha kill error here
                raise CaptchaError, @result[:error_msg]
            end
        end
    end
    
    def balance_post_data(username=nil, password=nil)
        username = GlobalSettings.instance.get_var(:decaptcher_username) if !username
        password = GlobalSettings.instance.get_var(:decaptcher_password) if !password

        post_data = MultipartBody.new(
            :function => 'balance',
            :username => username,
            :password => password
        )
        post_data
    end

    def validated?( username, password )
      #this is a syncrounous function and should
      #only be called from our global setting captcha
      #validation routines.
      #should just return true if no error
      #false if there was an error

        begin

          agent = Mechanize.new
		      #agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
          agent.read_timeout = 60  #set the agent time out

          server_url = init_server()
          post_data = balance_post_data( username, password )
          head = init_headers( post_data )

          #puts "Validating Decaptcher using Username / Password : #{username} / #{password}"

          #run the request here
          agent.post( server_url, post_data.to_s, head )
          result = agent.page.body.to_s
          agent.history.pop()   #delete this request in the history
        
          return false if result.empty?
          return true if result.is_float?
          return true if result.is_integer?

          false

        rescue Timeout::Error
          false
        end
    end

    def solve()

        info("[Decaptcher Service] -- Solving Captcha -- Retry : #{@retry}")

        if max_retries_met?()

            error = @result[:error_msg] ? @result[:error_msg] : "Max Retries Met for DeCaptcha Server"
            raise CaptchaError, error

        else
            init_post_data()
            init_server()
            init_headers()
            #stat_captcha_decaptcher_inc
            super()
        end
        
    end
end
