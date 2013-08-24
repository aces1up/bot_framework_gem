

class VerifyEmail < Action

    attr_accessor :subject, :email_retry, :interval, :email_type

    def init()
        @subject      =  nil
        @email_type   =  :catchall        
        @email_retry  =  4
        @interval     =  15
        @email        =  self[:email]
        @creds        =  self[:catchall_data]
        
        @retry_count      =  0
        @pop              =  nil  #<--- our pop object handling email checking
        @email_msg_obj    =  nil  #<--- the email object of our found message
        @email_text       =  nil  #<--- the email text of our found email
        @err              =  nil  #<--- our error object if there was one.
    end

    def dump_error()
        @err ? "[Error]: #{@err.class.to_s} -- #{@err.message}" : ""
    end

    def server()
        @creds[:server]
    end

    def email_settings()
        {
           :address    => @creds[:server],
           :port       => @creds[:port],
           :user_name  => @creds[:username],
           :password   => @creds[:password],
           :enable_ssl => false
        }
    end

    def retry_met?()
        @retry_count >= @email_retry
    end

    def do_retry()
        @retry_count += 1
        sleep( @interval )
    end
    
    def cleanup()
        #cleans up the pop connection during retry interval
        #to ensure we don't get too many connection errors
        #from isp
    end

    def found_email?()
        !@email_msg_obj.nil?
    end

    def check()

        info("Checking Email -- Retry [ #{@retry_count} / #{@email_retry} ]")

        #returns found email if we match
        @pop.find( :what => :last, :count => 10, :order => :desc ).each do |message|

            #check to field
            if @email   ;  next if @email.downcase != message.to.first.downcase end

            #check subject field
            if @subject ;  next if !message.subject.downcase.include?( @subject.downcase )  end

            @email_msg_obj = message

            @email_text = message.body.decoded
            @email_text.gsub!( /\r/, '' )
            @email_text.gsub!( /\n/, '' )

            return
        end
    end

    def connect()
        info("Connecting to Email Server Using: #{email_settings.inspect}")
        @pop = Mail::POP3.new( email_settings )
        info("Connected to Email Server!")
    end

    def run()

        @email        =  self[:email]
        @creds        =  self[:catchall_data]

        raise EmailError, "Cannot Verify Email, No Credentials Set!" if !@creds
        
        debug("Using Email Login Data: #{email_settings.inspect}")
        info("Verifying Email [ Email: #{@email} ] -- [ Subject: #{@subject} ]")

        while ( !found_email? and !retry_met? )
            begin

                connect()
                check()
                cleanup()

                do_retry

            rescue => err

               cleanup

               case err.class.to_s

                  when  /POPAuthenticationError/
                        raise EmailError, "Could Not Verify Email! -- Error : Authentication Failed"
                  when  /ECONNREFUSED/
                        raise EmailError, "Could Not Verify Email! -- Error : Could not Connect to Email Server : #{server}"
                  when  /SocketError/
                        raise EmailError, "Could Not Verify Email! -- Error : Could not Connect to Email Server : #{server}"

               else
                  @err = err
                  warn( "Got Email Err: #{err.message}" )

                  if !retry_met?
                    do_retry
                    retry
                  end
               end
               
            end
        end


        if found_email?
            #save email to a temp variable here
            info("Found Email -- [ Subject: #{@email_msg_obj.subject} ]")
            self[:email_text] = @email_text
        else
            raise EmailError, "Could Not Verify Email! #{dump_error}"
        end

    ensure
        cleanup   #<--- make sure we close email connection before exiting.
    end

end


