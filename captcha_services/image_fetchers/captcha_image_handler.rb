

class CaptchaImageFetcher

    include BotFrameWorkModules
    include RecaptchaImageFetcher
    include NormalImageFetcher
    include SnapShotFetcher

    attr_reader :image_data

    def initialize( args={} )

        @args          = args                #<---- our tag args from Captcha Tag
        @image_data    = nil                 #<---- holds our retreived image data.
                                             #<---- if we are saving to disk, stores
                                             #      the filename we saved the image data to.
                                             
        @agent_var     = nil                 #<---- agent used for fetching image.
                                             #<---- set to nil so we first use the :agent
                                             #<---- main connection
    end

    def captcha_filename()
        "#{CaptchaDirectory}captcha-#{rand(999999999)}.png"
    end

    def save_as(filename, data)
        ::File::open( filename , "wb") { |f| f.print data }
    end

    def save_captcha_to_disk()
        save_as( captcha_filename, html )
        puts("[Captcha Solver] -- Saved Captcha Image to Disk. -- Filename: #{filename}")
    end

    def save_image()
        puts("[Captcha Solver] -- Saving Captcha Image to Memory -- [ #{html.length} ] Bytes") if !SaveCaptchaImagestoDisk
        SaveCaptchaImagestoDisk ? save_captcha_to_disk : @image_data = html
    end

    def fetch_captcha_image()
        begin

            @agent_var         = :image_fetcher
            @connection_class  = MechanizeConnection

            #check if we want to transfer cookies here
            cookie_from_main if @args[:use_cookies]
            get( @image_url )


        rescue => err
            raise CaptchaError, ("[Solve Captcha] -- Unable to Retrieve Image: #{@image_url} -- Error: #{err.message}")
        end

    end

    def store_image()
      begin
        fetch_captcha_image()
        save_image()
      ensure
        cleanup_connection if ( @agent_var and @agent_var == :image_fetcher )
      end
    end


    def get_solve_mode()
        return :direct_url     if @args[:use_url]
        return :captcha_coords if @args[:image_coords]
        return :image_search   if @args.has_key?(:search_for) and !@args[:search_for].empty?
        return :recaptcha      if @args[:is_recaptcha]
        :unknown
    end

    def store_captcha_image()

        #info("[Captcha Solver] -- Determining Captcha Image.")
        #debug("Determining Captcha Image -- Args: #{args.inspect}")

        solve_mode = get_solve_mode

        case solve_mode

           when :direct_url

                #need to first run tag solver on the :use_url to
                #parse any tags it might have included
                info("Setting Captcha Mode to Direct URL.")
                solve_tag( @args[:use_url] )

           when :image_search

                puts("[Captcha Solver] -- Determined Captcha Type -- [ Force Normal Image ]")
                store_normal_image()

           when :recaptcha

                info("[Captcha Solver] -- Attempting to solve Captcha Type -- [ ReCaptcha ]")
                store_recaptcha_image()

           when :captcha_coords
             
                info("[Captcha Solver] -- Attempting to Retrieve Captcha SnapShot")
                fetch_snapshot()

           when :unknown

                raise CaptchaError, "[Captcha Solver] -- Unable to Determine Solve Mode from Tag Options!"

        end

    end
end