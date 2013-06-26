

module NormalImageFetcher

    def get_normal_image_url()
        puts("[Captcha Solver] -- Getting Normal Image Using: #{@args[:search_for].inspect}")

        searches = @args[:search_for].is_a?(Array) ? @args[:search_for] : [ @args[:search_for] ]
        found_url = searches.find{ |search_url| find_image_url( search_url ) }
        return false if !found_url
        
        find_image_url( found_url )
    end

    def store_normal_image()
        puts("[Captcha Solver] -- Determining Captcha Image Location")

        @image_url = get_normal_image_url()

        if !@image_url then
            raise CaptchaError, "[Captcha Solver] -- Could not Determine Captcha Image Location!"
        else
            puts("[Captcha Solver] -- Image Location: #{@image_url.inspect}")
            store_image()
        end
    end
end