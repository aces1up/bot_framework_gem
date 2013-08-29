

class DragandDrop < Action

    def init()
        init_element_vars
    end

    def dropto_find_args()
        Hash[* [ :dropto_method, :dropto_how, :dropto_what, :dropto_match_type, :dropto_wait_mode, :dropto_timeout ].map{ |data_arg|
               data_var = data_arg.to_s.gsub('dropto_','').to_sym
               [ data_var , @data[ data_arg ] ]
          }.flatten ]
    end

    def run()

        debug "Using DropTo Find Element -- #{dropto_find_args.inspect}"

        from_element     = VerifyElement.new( @data ).run
        drop_to_element  = VerifyElement.new( dropto_find_args ).run

        info "Doing Drag and Drop..."
        info "DragtoElement Found: [ #{drop_to_element.element.obj_info} ] -- [ #{drop_to_element.tag_name} ] -- [ ID: #{drop_to_element.id} ]"

        from_element.drag_to( drop_to_element )

    end

end

