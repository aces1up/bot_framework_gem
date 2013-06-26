

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

    def fullname()
        #"#{self[:first_name]} #{self[:last_name]}"
        solve_multiple_tags( [:first_name, :last_name] )
    end

    def get_bio_var(var)
        #goes out to our bio files and gets a random
        #element from the file that our var corresponds to
        #ex.  var == :first_name  --  Filename : bio/first_name.data
        bio_file = "#{BioDirectory}#{var.to_s}.data"
        rand_file_line( bio_file )
    end



  
end
