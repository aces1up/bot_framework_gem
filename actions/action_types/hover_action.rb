

class HoverElement < Action

    def init()
        init_element_vars
    end

    def run()
        found = VerifyElement.new( @data ).run

        case @data[:hover_mode]
            when :native
                info "Hovering on Found Element Using Native Method: #{found.obj_info}"
                found.hover

            when :javascript
                info "Hovering on Found Element Using JavaScript Method: #{found.obj_info}"
                found.hover_js

        end

    end

end
