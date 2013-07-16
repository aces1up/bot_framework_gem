

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
            raise CaptchaError, "[Captcha Solver Fatal Error] -- #{err.message}\n#{err.backtrace.join("\n")}"
        end


    end
    
    def get_content( content_tag )
        ArticleTagHandler.new( content_tag, @tag_args ).return_content
    end

    def article_text()
        get_content( :article_text )
    end

    def article_title()
        get_content( :article_title )
    end

    



  
end
