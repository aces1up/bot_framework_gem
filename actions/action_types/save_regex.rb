

class SaveRegex < Action

    attr_accessor :search_string, :save_to_temp, :save_var, :overwrite

    def init()
        @search_string = nil
        @save_to_temp  = true
        @overwrite     = true
        @save_var      = nil
    end

    def run()
        raise ActionError, 'Cannot Save Regex, no Search String Specified!' if !@search_string
        raise ActionError, 'Cannot Save Regex, no Save Variable Specified!' if !@search_string

        html =~ Regexp.new( @search_string )
        @save_val = $1

        if @save_val
            do_save()
        else
            raise ActionError, "Cannot Find Regex: #{@search_string} in Current HTML!"
        end

    end
end
