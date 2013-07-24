

module EnviornmentHelper

    def set_env_var(var, val, container=:temp)
        add( {var => val}, container )
    end

    def set_function( function_name )
        set_env_var( :function, function_name, :site )
    end

    def set_status( status )
        set_env_var( :status, status, :site ) if has_var_mediator?
    end
    
    def set_log_handler( obj )
        set_env_var( :log_handler, obj, :site )
    end

    def clear_log_handler()
        set_env_var( :log_handler, nil, :site )
    end
    
    def get_log_handler( thread=nil )
        #attempts to get gui_table obj via the :site container
        #var --> :gui_loc
        return nil if !has_var_mediator? and !thread

        handler = thread ? thread.get_var( :log_handler ) : self[:log_handler]

        handler ? handler : nil
    end

end
