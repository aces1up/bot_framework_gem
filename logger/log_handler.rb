

module LogHandler

    def msg_str( log_level, msg )
        "#{time} -- #{log_level.to_s.upcase}: #{msg}"
    end

    def do_log( log_level, msg, thread=nil )

        thread ||= Thread.current

        if Display_GUI

            table_obj = get_gui_table_obj( thread )
            if table_obj
                #add a :site container shared var for the log level
                #we are processing
                thread.set_var( { log_level => msg }, :site)
                table_obj.update( thread )
            end

            #puts( msg_str( log_level, msg ) )
        else
            puts( msg_str( log_level, msg ) )
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

    def debug( msg="" )
        return if !log_level_met?( :debug )
        msg = msg_str( :debug, msg )
        do_log( :debug, msg )
    end

    def error( msg="", thread=nil )
        return if !log_level_met?( :error )
        do_log( :error, msg, thread )
    end

    def fatal( msg="" )
        return if !log_level_met?( :fatal )
        do_log( :fatal, msg )
    end

end
