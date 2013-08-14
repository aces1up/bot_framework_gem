

class GlobalSettings < Settings

    include Singleton

    def initialize()
        super
        @settings_file   = SettingsFile
    end


end

