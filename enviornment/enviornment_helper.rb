

module EnviornmentHelper

    def clear_gui_error()
        return if !Display_GUI
        error("")
    end

    def update_gui()
        return if !Display_GUI
        table_model = get_gui_table_obj
        table_model.update() if table_model
    end

    def set_env_var(var, val, container=:temp)
        add( {var => val}, container )
    end

    def set_function( function_name )
        set_env_var( :function, function_name, :site )
    end

    def set_status( status )
        set_env_var( :status, status, :site ) if has_var_mediator?
        update_gui()
    end
    
    def set_gui_table_location(location)
        set_env_var( :gui_loc, location, :site ) 
    end
    
    def get_gui_table_obj( thread=nil )
        #attempts to get gui_table obj via the :site container
        #var --> :gui_loc
        return nil if !has_var_mediator? and !thread

        location = thread ? thread.get_var(:gui_loc) : self[:gui_loc]
        return nil if !location
        
        DashboardGuiController.instance.send( location )
    end

end
