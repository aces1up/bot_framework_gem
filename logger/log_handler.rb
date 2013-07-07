

module LogHandler

    def msg_str( log_level, msg )
        "#{time} -- #{log_level.to_s.upcase}: #{msg}"
    end
    
    def do_log( log_level, msg, thread=nil )

        #check if we have a log handler for this thread.
        if ( log_handler = get_log_handler( thread ) )

            thread ||= Thread.current
            return if !log_handler.respond_to?( :update_msg )

            log_handler.update_msg( msg, log_level, thread )

        else
            msg_output = msg_str( log_level, msg )
            puts( msg_output )
        end
        
    end

    def get_log_level(log_method)
        Kernel.const_get('Logger').const_get(log_method.to_s.upcase)
    end

    def log_level_met?( log_method )
        severity_level     = get_log_level( log_method )
        global_log_level   = get_log_level( LogLevel )

        ( severity_level >= global_log_level )
    end

    def info( msg="" )
        return if !log_level_met?( :info )
        msg = msg_str( :info, msg )
        do_log( :info, msg )
    end

    def warn( msg="" )
        return if !log_level_met?( :warn )
        msg = msg_str( :warn, msg )
        do_log( :warn, msg )
    end

    def debug( msg="" )
        return if !log_level_met?( :debug )
        msg = msg_str( :debug, msg )
        do_log( :debug, msg )
    end

    def error( msg="", thread=nil )
        return if !log_level_met?( :error )
        #we call do_log with the thread that has our
        #thread vars IF we are getting called by
        #an exception that was tirggered outside of our normal thread.
        do_log( :error, msg, thread )
    end

    def fatal( msg="" )
        return if !log_level_met?( :fatal )
        do_log( :fatal, msg )
    end

end
