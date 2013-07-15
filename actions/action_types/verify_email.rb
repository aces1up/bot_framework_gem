

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

    def email_settings()
        {
           :address    => @creds[:server],
           :port       => @creds[:port],
           :user_name  => @creds[:user],
           :password   => @creds[:pass],
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

        #returns found email if we match
        @pop.find( :what => :last, :count => 10, :order => :desc ).each do |message|

            #check to field
            next if @email != message.to.first

            #check subject field
            if @subject ; next if !message.subject.include?( @subject )  end

            @email_msg_obj = message

            @email_text = message.body.decoded
            @email_text.gsub!( /\r/, '' )
            @email_text.gsub!( /\n/, '' )

            return
        end
    end

    def connect()
        info("Connecting to Email Server: #{@creds[:server]}")
        @pop = Mail::POP3.new( email_settings )
    end

    def run()

        debug("Using Email Login Data: #{@creds.inspect}")
        info("Verifying Email [ Email: #{@email} ] -- [ Subject: #{@subject} ]")

        while ( !found_email? and !retry_met? )
            begin

                info("Checking Email -- Retry [ #{@retry_count} / #{@email_retry} ]")
                connect()
                check()
                cleanup()

                do_retry

            rescue => err
               cleanup
               @err = err

               if !retry_met?
                  do_retry
                  retry
               end
            end
        end


        if found_email?
            #save email to a temp variable here
            info("Found Email -- [ Subject: #{@email_msg_obj.subject} ]")
            self[:email_text] = @email_text
        else
            raise ActionError, "Could Not Verify Email! #{dump_error}"
        end

    ensure
        cleanup   #<--- make sure we close email connection before exiting.
    end

end


