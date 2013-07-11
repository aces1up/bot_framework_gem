

class IframeAction < Action

    def init()
        init_element_vars
    end

    def iframe_find_args()
        Hash[* [ :iframe_method, :iframe_how, :iframe_what, :iframe_match_type ].map{ |data_arg|
               data_var = data_arg.to_s.gsub('iframe_','').to_sym
               [ data_var , @data[ data_arg ] ]
          }.flatten ]
    end

    def manipulate( iframe )
        case @data[:manipulation_mode]

            when :set_element
                solved = solve_tag( @data[:set_value] )
                info "Setting Iframe Element with Value : #{solved.inspect}"
                #iframe.click
                iframe.focus
                sleep(0.3)
                iframe.set( solved )

            when :click
                info "Clicking Iframe Element...."
                iframe.click

            when :hover_js
                info "Hovering on Iframe Element using JavaScript Method.."
                iframe.hover_js

            when :hover
                info "Hovering on Iframe Element using Normal Method.."
                iframe.hover
        end
    end

    def run()

        found = VerifyElement.new( @data ).run

        load_args = iframe_find_args.merge( { :start_element => found } )
        debug "Using Iframe Find SubElement Data args: #{load_args.inspect}"

        iframe = VerifyElement.new( load_args ).run
        info "Iframe Found: [ #{iframe.element.obj_info} ] -- [ #{iframe.tag_name} ] -- [ ID: #{iframe.id} ]"
        
        debug "Iframe HTML : #{iframe.element.html}" if @data[ :show_html ]

        manipulate( iframe )

    end

end
