

class CaptchaService

    include BotFrameWorkModules

    def initialize(creds, image_data)

        @creds = creds
        @image_data = image_data

        @connection_class = MechanizeConnection

        @retry = 0
        @result = {}                #<--- our result hash containing our result variables

        @force_local_proxy = true   #<--- make sure we are using local ip for all Captcha Requests.

        init()                      #<--- call the init on our subclasses
    end

    def max_retries_met?()
        @retry >= MaxCaptchRetry
    end

    def post_data_validated?
        !html.empty?
    end

    def raise_post_error()
        raise CaptchaError, "[Captcha Service] -- Captcha Server Returned no Data!"
    end

    def solve()
        @retry += 1
        debug("Doing Captcha Service POST here")
        #info("Sending Post Data:\n#{@post_data.to_s}")

        #set up a temp agent for processing our captcha image
        @agent_var         = :captcha_agent
        @use_local_proxy   = true


        #stat_captcha_sent_inc
        begin
            begin
                post( @server_url, @post_data.to_s, @headers )
            rescue => err
                raise CaptchaError, "Failed Posting Data to #{self.class.to_s.sub('Solver', '')} Server -- Error: #{err.message}"
            end
            
            #check if our post data is valid, and if so, handle the response..
            #if not then retry the submit if we still have retries left.
            if post_data_validated?
                handle_response()
            else
                #if max retries met? then raise an error that we were
                #not able to validate post data.
                #else run the solve method again.
                max_retries_met? ? raise_post_error : solve
            end

        ensure
            cleanup_connection
        end

    end
end
