

module GlobalWrapper

    def global_var( var )
        GlobalSettings.instance.get_var( var )
    end

    def set_var( var, value, save_settings=false )
        GlobalSettings.instance.set_var( var, value, save_settings )
    end

    def all_global_settings()
        GlobalSettings.instance.settings
    end

    def global_set_constants()
        GlobalSettings.instance.set_constants
    end

    def global_merge( settings={}, overwrite_if_exists=false )
        GlobalSettings.instance.merge_settings( settings, overwrite_if_exists )
    end
end
