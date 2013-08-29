
module ElementVarsHelper

    attr_accessor :method, :how, :what, :match_type, :start_element
    attr_accessor :wait_mode, :timeout, :raise_error, :use_xpath, :find_invisible
    attr_accessor :ele_index

    def dump_element()
        "[Method: #{@method}] -- [#{@how.inspect}] -- [What: #{@what}] -- [Match: #{@match_type}] -- [Wait Mode #{@wait_mode.inspect}] -- [Timeout: #{@timeout}]"
    end

    def init_element_vars()
        @method         = nil
        @how            = nil
        @what           = nil
        @match_type     = :broad
        @start_element  = nil
        @wait_mode      = :none
        @timeout        = nil
        @raise_error    = true
        @use_xpath      = false
        @find_invisible = false
        @ele_index      = nil
    end
end
