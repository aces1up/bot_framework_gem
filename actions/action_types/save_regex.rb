

class SaveRegex < Action

    attr_accessor :search_string

    def init()
        @search_string = nil
        init_save_vars()
    end

    def run()
        raise ActionError, 'Cannot Save Regex, no Search String Specified!' if !@search_string
        raise ActionError, 'Cannot Save Regex, no Save Variable Specified!' if !@save_var

        html =~ Regexp.new( @search_string )
        @save_val = $1

        if @save_val
            do_save()
        else
            raise ActionError, "Cannot Find Regex: #{@search_string} in Current HTML!"
        end

    end
end
