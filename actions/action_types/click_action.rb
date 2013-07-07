
class ClickElement < Action

    def init()
        init_element_vars
    end

    def run()
        found = VerifyElement.new( @data ).run
        info "Clicking Found Elmement: #{found.obj_info}"
        found.click
    end

end
