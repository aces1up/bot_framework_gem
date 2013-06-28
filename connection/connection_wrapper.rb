

#implements method missing to
#support calling of connection methods
#easily if they don't exist or have not been specifically routed

module ConnectionWrapper

    include LogHandler
    include ElementWrapper

    def cleanup_connection()
        return if @agent_var.nil?
        conn_mediator.cleanup( @agent_var )
    end

    def current_connection_handle(conn_name=nil)
        #returns the current connection handle for
        #the @agent_var specified
        init_connector()
        conn_name ||= @agent_var
        conn_mediator[ conn_name ]
    end

    def cookie_from_main( connection_name=nil )
        connection_name ||= @agent_var
        init_connector
        conn_mediator.cookie_from_main( connection_name )
    end

    def get_connection_class_from_string()
        begin ; Kernel.const_get(@connection_class) ; rescue
            raise ConnectionError, "Could Not Convert Connection Class: #{@connection_class.inspect}"
        end
    end

    def init_connection_class()

        #if the object we extended this into already has a @connection_class Variable
        #then use that as the connection class to create
        #else set the default value to MechanizeConnectorClass

        @connection_class ||= MechanizeConnection
        @connection_class = get_connection_class_from_string() if @connection_class.is_a?(String)

        debug("Initializing connection Class: #{@connection_class.inspect} -- #{@agent_var.inspect}")

        args = @use_local_proxy ? {:use_local_proxy => true} : {}
        Thread.current[:conns][@agent_var] = @connection_class.new( args )
    end

    def current_connector()
        #returns the current connector for the @agent_var this wrapper is using
        Thread.current[:conns][@agent_var]
    end

    def current_connection_type( ret_symbol=true )
        klass = current_connector.class.to_s.gsub('Connection','').downcase
        ret_symbol ? klass.to_sym : klass
    end

    def request_count()
        init_connector
        #gets the current request count for the current connection
        Thread.current[:conns].request_count(@agent_var)
    end

    def conn_mediator()
        #returns the connection mediator for the current thread.
        Thread.current[:conns]
    end

    def init_connection_mediator()
        Thread.current[:conns] ||= ConnectionMediator.new( @clone_thread, @clone_agent )
    end

    def init_connector()
        @agent_var ||= :agent
        #debug("Using @agent_var Connection Adapter -- @agent_var: #{@agent_var.inspect}")

        init_connection_mediator()
        init_connection_class() if !conn_mediator.connection_exists?(@agent_var)

        debug("Connection Wrapper using : [Agent Var: #{@agent_var.inspect}] -- [Connection Class: #{current_connector.class.to_s}]")
    end

    def is_connection_method_call?(method)
        Connection.instance_methods.include?(method)
    end

    def execute_connector_call(method, args)
        conn_mediator.execute_connector_call( @agent_var, method, args )
    end


    def method_missing(method, *args)

       super if !is_connection_method_call?(method)

       debug("Connection Wrapper Method Missing -- [Method: #{method.inspect}]") #-- [Args: #{args.inspect}] -- ")

       init_connector()

       #this executes the connector call and wraps the resulting
       #element if needed
       element = execute_connector_call( method, args )
       wrap( element, method )

    end
end
