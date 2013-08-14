

class Settings

    attr_reader    :settings
    attr_accessor  :settings_file

    def initialize()
        @settings      = {}
        @loaded        = false  #<--- set to true when settings have been loaded

        @settings_file   = nil
        @protect_hash    = {}
    end

    def set_file( filename )
        @settings_file = filename
    end

    def use_protect_hash( hash )
        #used for protecting variables held in @settings_file
        @protect_hash = hash
    end

    def reload()
        @loaded = false
        load
    end

    def load()
        return if @loaded
        return if !@settings_file

        return if !File.exist?( @settings_file )
        @settings = load_yaml_from_file( @settings_file )
        @settings = {} if !@settings.is_a?(Hash)
        @loaded = true
    end

    def set_constants()
        @settings.set_constants
    end

    def merge_settings( settings={}, overwrite_if_exists=false )
        load()

        @settings.merge!( settings ){ |key, v1, v2|
               overwrite_if_exists ? v2 : v1
        }

        save()
        set_constants()
    end

    def save()
        return if !@settings_file
        File.open( @settings_file, 'w' ) do |out| YAML.dump( @settings, out ) end
    end

    def set_var( var, value, save_settings=false )
        load()
        @settings[var] = value
        save if save_settings
    end

    def protect_var(var)

        max = @protect_hash[ "#{var.to_s}_max".to_sym ]
        return @settings[var] if max.nil?

        if @settings[var] > max
            #revert to the max for this variable and
            #save it back to protect from editing the
            #settings directly.
            @settings[var] = max
            save
        end

        @settings[var]

    end

    def var_exists?( var )
        @settings.has_key?( var )
    end

    def all_vars()
        @settings.inject( {} ) do | result, ( var, val )| 
            result[var] = get_var( var )
            result
        end
    end

    def get_var(var)
        load()
        #1.  Check if var exists in settings
        #2.  If not, check if its in Default settings
        #3.  If in Default, set default value

        @settings[var].nil? ? GlobalSettingDefaults[var] : protect_var(var)
    end

end


