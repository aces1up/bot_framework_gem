

class VerifyElement < Action

    attr_accessor :method, :how, :what, :match_type

    def init()
        @method     = nil
        @how        = nil
        @what       = nil
        @match_type = :broad
    end

    def dump_element()
        "[Method: #{@method}] -- [#{@how.inspect}] -- [What: #{@what}] -- [Match: #{@match_type}]"
    end

    def run()

        found = find( @method, @how, @what, @match_type )

        if !found
            raise ActionError, "Cannot verify Element: #{dump_element} on Page!"
        end

    end

end
