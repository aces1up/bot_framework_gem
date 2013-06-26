

class FormAction < Action

    def init()
        @solver = HintSolver.new( @data[:hints] )
        @form   = nil     #<--- form element we are processing with this Action
    end

    def select_form()
        @form = @solver.find_form( current_connection_handle )
        raise ActionError, "Cannot Determine form to use using Hint Data." if !@form
    end

    def fill_out_form()
        @form.solve( @solver )
    end

    def submit_form()
        @form.submit
    end

    def run()
        select_form()
        fill_out_form()
        submit_form()

        #send out html saving message htmlto the message handler for logging.
        puts "saving message html"
        message_html( html )
    end

end
