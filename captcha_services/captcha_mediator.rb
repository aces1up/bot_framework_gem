

class CaptchaMediator

    include BotFrameWorkModules

    def initialize( image_data )

        @image_data = image_data

        @services   = nil  #<---  array that is intialize with the services we can provide to solve this
                           #<---  captcha, it is shifted to the left each time we are done with a service
                           #      this will be a class list of the classes used for solving this captcha
        @captcha    = nil  #<---- the solved captcha

    end
    
    def valid_login_creds?(cap_service)
        username = GlobalSettings.instance.get_var("#{cap_service.to_s}_username".to_sym)
        password = GlobalSettings.instance.get_var("#{cap_service.to_s}_password".to_sym)

        return false if ![username, password].all?{|cred| !cred.nil? and !cred.empty? }
        
        {:creds => { :username => username, :password => password } }
    end

    def get_service_creds(service_name)

        if ( login_creds = valid_login_creds?( service_name ) )
           login_creds.merge!( :service => Kernel.const_get( "#{service_name.to_s.capitalize}Solver" ) )
           login_creds
        else
           nil
        end

    end

    def load_services()

        #@services = [ {:service => DecaptcherSolver, :username => decaptcher_username, :password => decaptcher_password} ]

        services = AvailableCaptchaServices.dup
        settings_default_service = GlobalSettings.instance.get_var(:default_captcha_service)
        default_service = settings_default_service ? settings_default_service : DefaultCaptchaService
        services_run_order = [ services.delete( default_service ) ]
        services_run_order += services

        @services = []
        @services = services_run_order.map{ |service| get_service_creds( service ) }.compact

        debug "Loaded Captcha Mediator Services: #{@services.inspect}"
    end

    def load_image_data()

      begin
        #don't need to load from file if we have set savecaptchatodisk
        return if !SaveCaptchaImagestoDisk
        filename = @image_data.dup
        File.open(filename, "rb") do |data| @image_data = data.read end
      ensure 
         #make sure we delete the captcha file here.
         del_file( filename ) if filename
      end

    end

    def raise_solve_error()
        raise CaptchaError, "[Captcha Solver] -- Unable to Solve Captcha, all Captcha Services failed..."
    end

    def solve()
        info("[Captcha Solver] -- Loading Captcha Service")

        #first load our image data
        load_image_data()
        info("Loaded Image Data -- #{@image_data.length} Bytes")

        #load our services here
        load_services()

        #raise error here if we were unable to load any services
        if @services.empty?
            raise CaptchaError, "Cannot Solve Captcha, Unable to find Login Credentials for any Captcha Service!"
        end

        #figure out what we do here when no more services are available
        while (cap_solver = @services.shift) and @captcha.nil? do
          
            begin

                cap_solver_obj = cap_solver[:service].new( cap_solver[:creds], @image_data )
                @captcha = cap_solver_obj.solve

            rescue CaptchaError => err
                puts err.message
            end

        end

        @captcha ? @captcha : raise_solve_error

    end
end
