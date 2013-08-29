

module NormalImageFetcher

    def get_normal_image_url()
        info("[Captcha Solver] -- Getting Normal Image Using: #{@args[:search_for].inspect}")

        searches = @args[:search_for].is_a?(Array) ? @args[:search_for] : [ @args[:search_for] ]
        found_url = searches.find{ |search_url| find_image_url( search_url ) }
        return false if !found_url
        
        find_image_url( found_url )
    end

    def store_normal_image()
        info("[Captcha Solver] -- Determining Captcha Image Location")

        retry_count = 0

        begin

            @image_url = get_normal_image_url()

            if !@image_url then
                raise CaptchaImageFetchError, "[Captcha Solver] -- Could not Determine Captcha Image Location!"
            else
                info("[Captcha Solver] -- Image Location: #{@image_url.inspect}")
                store_image()
            end
            
        rescue CaptchaImageFetchError => err
            if retry_count < 5 
              
                retry_count += 1
                info("Count not Determine Image Location... Retrying.. #{retry_count} / 5")
                sleep(1)
                retry
                
            else
                raise
            end
        end

    end
end