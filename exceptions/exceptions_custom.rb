
class FatalAppError < StandardError

    include BotFrameWorkModules

    attr_accessor :klass

    def self.log_file()
        #returns the location of this log_file and creates if it
        #doesn't exist.
        "#{LogsDir}BotFatalError.log"
    end

    def set_klass( klass )
        @klass = klass
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
        "[ Exception Error: Klass #{@klass.to_s} : Msg: #{message} ]\n[Backtrace: #{backtrace.join("\n")}]"
    end

    def report_gui( thread )
        #set the error directly on thread vars
        #using our thread var mediator access methods.
        error( msg, thread )
    end

    def report( thread=nil )

        thread ||= Thread.current
        return if !has_var_mediator?

        #set the function status via the thread set functions here
        thread.set_var( { :status => status_msg }, :site )

        @logger ||= self.class.init_log
        @logger.fatal( msg )

        #puts "Exception : #{msg}"
        set_error( msg )
        report_gui( thread )
    end

end


class GeneralAppException < FatalAppError

    def self.log_file()
        "#{LogsDir}BotFunctionError.log"
    end

    def status_msg() ; :error end
    def msg()
        "[ Error: #{message} ]"
    end
end

class BotThreadTimeout  < GeneralAppException
    def status_msg() ; :timeout end
end


class ConnectionError          < GeneralAppException    
    def status_msg() ; :connection_error end
end

class FatalConnectionError     < FatalAppError          ; end

class HardwareError        < FatalAppError              ; end
class ProcessHardwareError < HardwareError              ; end



class TagSolverError    < GeneralAppException    ; end
class CaptchaError      < GeneralAppException    
    def status_msg() ; :captcha_error end
end
class CaptchaImageFetchError      < CaptchaError ; end

class CacheError                 < FatalAppError          ; end
class FunctionNotImplemented     < FatalAppError          ; end

class EnviornmentError  < FatalAppError          ; end
class StartupError      < FatalAppError          ; end
class DeadSite          < GeneralAppException    ; end
class RawPostError      < GeneralAppException    ; end
class ActionError       < GeneralAppException    ; end
class EmailError        < GeneralAppException
   def status_msg() ; :email_error end
end

class NoElementFound        < GeneralAppException ; end


class FunctionError     < GeneralAppException    ; end
class ContentError      < GeneralAppException    
    def status_msg() ; :content_error end
end

class LoginError        < GeneralAppException    
    def status_msg() ; :login_error end
end





