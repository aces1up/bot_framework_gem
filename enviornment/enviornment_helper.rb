

module EnviornmentHelper

    def set_profile( profile_data )
        add( profile_data, :acct, true, true )
    end

    def set_env_var(var, val, container=:temp)
        add( {var => val}, container )
    end

    def set_function( function_name )
        set_env_var( :function, function_name, :site )
    end

    def set_platform( platform )
        set_env_var( :platform, platform, :site )
    end

    def set_footprint( footprint )
        set_env_var( :footprint, footprint, :site )
    end

    def set_error( err )
        set_env_var( :error, err, :site )
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

        handler = thread ? thread.get_var( :log_handler ) : get_env_var( :log_handler )

        handler ? handler : nil
    end

end
