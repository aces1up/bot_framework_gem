
require 'rbconfig'

module OSResolver

    def is_linux?()
        Config::CONFIG['target_os'] =~ /linux/i
    end

    def is_win?()
        Config::CONFIG['target_os'] == /mswin/
    end

    def os()
        case
            when is_win?     ; :win
            when is_linux?   ; :linux
        else
            #default to windows enviornment
            :win
        end
    end

end
