

module Enviornment
    include EnviornmentHelper

    def init_vars( init_data={} )
        Thread.current[:vars] = VariableMediator.new( init_data )
        Thread.current.init_uuid
    end

    def get_clone_vars( thread=nil )
        #retrieves a hash of our :conns and :vars
        #thread vars for easy cloning later
        thread ||= Thread.current

        vars = {}
        [ :vars, :conns, :uuid ].each do |clone_var|
            next if !thread[clone_var]
            vars[clone_var] = thread[clone_var]
        end
        
        vars
    end

    def clone_vars( clone_with={} )
        #adds the clone_with hash vars to the current Thread local vars.
        clone_with.each do |clone_var, value| Thread.current[clone_var] = value end
    end
    
    def clear_temp_vars()
        clear_container( :temp )
    end

    def teardown_thread_connections()
        #tears down all the connections for current thread
        Thread.current[:conns].cleanup_all_connections if Thread.current[:conns]
        Thread.current[:conns] = nil
    end

    def teardown_thread_vars( save=false )
        Thread.current[:vars].save_all if ( Thread.current[:vars] and save )
        Thread.current[:vars] = nil
    end

    def teardown_thread_eviornment( save=false )
        Thread.current[:uuid] = nil
        teardown_thread_connections()
        teardown_thread_vars( save )
    end

    def set_clone_thread( agent=:agent)
        @clone_thread = Thread.current
        @clone_agent  = agent
    end

    def has_var_mediator?()
        Thread.current.key?(:vars)
    end

    def validate( attr='unknown' )
        raise EnviornmentError, "Cannot Retrieve Enviornment Variable : #{attr.inspect} -- No Var Mediator Set for Thread!" if !has_var_mediator?
    end

    def container_data( container )
        #retrieves the data hash held in container Specified
        validate('Container Data')
        Thread.current[:vars].container_data( container )
    end

    def save_container(container, *args)
        validate('Save Container')
        Thread.current[:vars].save_container( container, *args )
    end

    def container_empty?(container)
        validate('Container Empty')
        Thread.current[:vars].container_empty?( container )
    end

    def clear_container( container )
        validate('Clear Container')
        Thread.current[:vars].clear_container( container )
    end

    def var_keys()
        #returns a hash of var container / keys array
        #ex:
        #   :temp => [ :var1, :var2 ]
        #   :acct => [ :var3, :var4 ]
        validate()
        Thread.current[:vars].var_keys
    end
    
    def add(var_hash, var_container=:temp, overwrite=true, reset_container=false)
        validate( var_hash )

        Thread.current[:vars].add( var_hash, var_container, overwrite, reset_container )
    end


    def [](attr)
        validate(attr)

        Thread.current[:vars].send( :[], attr )
    end

    def []=( attr, val )
        validate(attr)

        Thread.current[:vars][attr] = val
    end

end
