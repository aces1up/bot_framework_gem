

class GlobalSettings

    include Singleton

    attr_reader :settings

    def initialize()
        @settings = {}

        @loaded = false     #<--- set to true when settings have been loaded
    end

    def reload()
        @loaded = false
        load
    end

    def load()
        return if @loaded
        return if !File.exist?( SettingsFile )
        @settings = load_yaml_from_file( SettingsFile )
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
    end

    def save()
        File.open(SettingsFile, 'w') do |out| YAML.dump( @settings, out ) end
    end

    def set_var( var, value, save_settings=false )
        load()
        @settings[var] = value
        save if save_settings
    end

    def protect_var(var)

        max = GlobalSettingDefaults[ "#{var.to_s}_max".to_sym ]
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

    def get_var(var)
        load()
        #1.  Check if var exists in settings
        #2.  If not, check if its in Default settings
        #3.  If in Default, set default value

        @settings[var].nil? ? GlobalSettingDefaults[var] : protect_var(var)
    end

end

