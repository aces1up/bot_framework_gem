
module ElementVarsHelper

    attr_accessor :method, :how, :what, :match_type, :start_element

    def dump_element()
        "[Method: #{@method}] -- [#{@how.inspect}] -- [What: #{@what}] -- [Match: #{@match_type}]"
    end

    def init_element_vars()
        @method         = nil
        @how            = nil
        @what           = nil
        @match_type     = :broad
        @start_element  = nil
    end
end
