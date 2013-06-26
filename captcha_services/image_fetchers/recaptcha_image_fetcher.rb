RecaptchaFootprints = ['RecaptchaOptions', 'recaptcha/api/challenge', 'recaptcha/api/']
RecaptchaPublicKeySearchers = [ /challenge\?.*k=(.*)"/, /noscript\?.*k=(.*)".*height/ ]

module RecaptchaImageFetcher

    def is_recaptcha?()
        RecaptchaFootprints.any? { |ele| html.include?(ele)}
    end

    def get_recaptcha_public_key()
        info("[Captcha Solver] -- Determining Recaptcha Public Key")

        return @args[:public_key] if @args[:public_key]

        RecaptchaPublicKeySearchers.each do |regex|
            result = html.scan(regex)
            puts "captcha image public key search: result: #{result.inspect}"
            next if !result or result.empty?
            return result[0][0]
        end

        false
    end
    
    def store_challenge_and_image_url()
        info("[Captcha Solver] -- Storing Recaptcha Challenge Code")
        result = html.scan(/challenge.*:.*'(.*)'/)
        if !result.empty? then

             @challenge_code = result[0][0]
             #add this to the shared_variables so that hopefully they
             #will be accessed properly by the tag handler later
             #for additional fields
             self[:chal] = @challenge_code
             info("[Captcha Solver] -- Determined Recaptcha Challenge Code -- #{@challenge_code}")
             @image_url = "http://www.google.com/recaptcha/api/image?c=#{@challenge_code}"

             #store the image here
             store_image()

         else
             raise CaptchaError, "[Captcha Solver] -- Unable to Determine Recaptcha Challenge Code"
         end
    end

    def get_recaptcha_challenge_code()
        @image_url = "http://www.google.com/recaptcha/api/challenge?k=#{@public_key}&ajax=1&cachestop=0.8543293215288007"

        info ("[Captcha Solver] -- Determining Recaptcha Challnge Code")
        fetch_captcha_image()
    end

    def store_recaptcha_image()
        @public_key = get_recaptcha_public_key
        if !@public_key then
            raise CaptchaError, "[Captcha Solver] -- Could not Determine Recaptcha Public Key!"
        else
            info("[Captcha Solver] -- Found Recaptcha Public Key : #{@public_key.inspect}")
            get_recaptcha_challenge_code()
            store_challenge_and_image_url()
        end
    end

end
