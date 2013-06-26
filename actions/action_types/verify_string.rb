

class VerifyString < Action

    attr_accessor :verify_string, :match_type

    def init()
        @verify_string = nil
        @match_type    = :broad
    end

    def solve_str()
        @solved ||= @verify_string.is_a?(String) ? solve_tag( @verify_string ) : @verify_string
        @solved
    end

    def found?()
        case @match_type
            when :exact  ;  html == solve_str
            when :broad  ;  html.include?( solve_str )
        end
    end

    def run()
        if found?
            info("Found Search String: #{solve_str} in HTML.")
        else
            err = "Cannot Verify Search String: #{solve_str.inspect} in Current HTML!"
            raise ActionError, err
        end
    end

end
