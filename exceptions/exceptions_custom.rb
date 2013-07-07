

class FatalAppError < StandardError

    include BotFrameWorkModules

    def self.log_file()
        #returns the location of this log_file and creates if it
        #doesn't exist.
        "#{LogsDir}BotFatalError.log"
    end

    def self.init_log()

        unless @logger
            @logger ||= Logger.new( log_file )
            @logger.datetime_format = "%H:%M %p"
        end
        
        @logger

    end

    def status_msg() ; :fatal ; end

    def msg()
        "[Error: #{message}]\n[Backtrace: #{backtrace.join("\n")}]"
    end

    def report_gui( thread )
        #set the error directly on thread vars
        #using our thread var mediator access methods.
        err_msg = "#{self.class.to_s} -- #{message}"
        error( err_msg, thread )
    end

    def report( thread=nil )

        thread ||= Thread.current
        return if !has_var_mediator?

        #set the function status via the thread set functions here
        thread.set_var( { :status => status_msg }, :site )

        @logger ||= self.class.init_log
        @logger.fatal( msg )

        #puts "Exception : #{msg}"

        report_gui( thread ) if Display_GUI
    end

end


class GeneralAppException < FatalAppError

    def self.log_file()
        "#{LogsDir}BotFunctionError.log"
    end

    def status_msg() ; :error end

end

class BotThreadTimeout  < GeneralAppException
    def status_msg() ; :timeout end
end


class ConnectionError          < GeneralAppException    
    def status_msg() ; :connection_error end
end

class FatalConnectionError     < FatalAppError          ; end

class TagSolverError    < GeneralAppException    ; end
class CaptchaError      < GeneralAppException    
    def status_msg() ; :captcha_error end
end
class CacheError        < FatalAppError          ; end
class EnviornmentError  < FatalAppError          ; end
class StartupError      < FatalAppError          ; end
class DeadSite          < GeneralAppException    ; end
class RawPostError      < GeneralAppException    ; end
class ActionError       < GeneralAppException    ; end
class FunctionError     < GeneralAppException    ; end
class LoginError        < GeneralAppException    
    def status_msg() ; :login_error end
end





