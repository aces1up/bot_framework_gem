

module Tags

    include FileHandlingTags
    include BioTags

    def captcha()

        begin
      
            fetcher = CaptchaImageFetcher.new( @tag_args )
            fetcher.store_captcha_image

            cap_med = CaptchaMediator.new( fetcher.image_data )
            cap_med.solve

        rescue => err
            raise CaptchaError, "[Captcha Solver Fatal Error] -- Fatal Error Encountered -- #{err.message}\n#{err.backtrace.join("\n")}"
        end


    end

    



  
end
