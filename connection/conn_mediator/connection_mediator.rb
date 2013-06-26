

#this is a container class that holds all connections assigned
#for posting in current thread context.

#this object is assigned on new runs / jobs to each
#thread for easy maintenance of connections and
#cookie transfers etc.


#we assume that :agent is the main connection...
#we assume this for cookie transfers.

class ConnectionMediator

    include ConnectionErrorHandler
    include ExecuteConnectorNormalCall
    include ExecuteConnectorFetchCall
    include LogHandler
    include Enviornment

    def initialize( clone_thread=nil, clone_agent=nil )
        @conns = {}   #<--- Structure of Conns
                      #<--- key : connection_name / handle
                      #       
                      #
                      #
        @conns_count = {}    #<--- maintains a count of fetch requests for each connection

        @clone_thread = clone_thread
        @clone_agent  = clone_agent
    end

    def [](attr)
        @conns[attr]
    end

    def request_count( connection_name )
        @conns_count[ connection_name ]
    end

    def connection_exists?(conn_name)
        !@conns[conn_name].nil?
    end

    def main_connection_exists?()
        !@conns[:agent].nil?
    end

    def main_connection()
        @conns[:agent]
    end

    def do_clone_thread?( connection_name )
        return false if @clone_thread.nil?
        #dont clone if @clone Thread matches current thread id
        return false if @clone_thread.__id__ == Thread.current.__id__
        return false if @clone_agent.nil?
        return false if @clone_agent != connection_name

        @clone_thread[:conns] and @clone_thread[:conns][connection_name]
    end

    def handle_clone_thread(connection_name)
        clone_handle = @clone_thread[:conns][connection_name]
        cur_handle   = self[connection_name]

        clone_cookies = clone_handle.cookies
        clone_uri     = clone_handle.cur_uri

        num_cookies = self[connection_name].load_cookies( clone_uri, clone_cookies )
        debug("[Clone Connection] -- Transferred [ #{num_cookies} ] Cookies to Connection : #{connection_name.inspect}:#{cur_handle.obj_info}")
    end

    def []=( connection_name, connection_handle )
        
        #check to see if this connection_name already exists, this should not 
        #happen and looks like a possible deeper issue, so raise an error here
        
        if connection_exists?(connection_name)
            raise ConnectionError, "Cannot add Connection : #{connection_name} -- It has already been Instantiated!"
        end

        @conns[connection_name]       = connection_handle
        @conns_count[connection_name] = 0
        debug "Connection Mediator Added:  [ #{connection_name.inspect} --> #{connection_handle.obj_info} ]"

        #check if we need to clone the thread here
        handle_clone_thread(connection_name) if do_clone_thread?(connection_name)
    end

    def cleanup_all_connections()
        #this will run teardown code on ALL our connection
        #currently Loaded
        @conns.each do |conn_name, handle| handle.teardown end
        @conns = {}
    end

    def cleanup( conn_name, raise_error=true )
        #this will raise error if we try and cleanup the main connection which
        #really should only happen at the end of a event run

        begin

            return if !connection_exists?(conn_name)
            if (raise_error and conn_name == :agent)
                raise ConnectionError, "Error Cleaning up Connection -- Error: Trying to Release Main Connection!"
            end

            #run the teardown method on the actual connection here
            debug "Cleaning up Connection: #{conn_name.inspect}"
            @conns[conn_name].teardown

        ensure
          #make sure we delete the connection here from the connection list.
          #so it doesn't raise error if we try and create it again.
          @conns.delete(conn_name)
          @conns_count.delete(conn_name)
        end
    end


    def raise_cookie_error(conn_name, to=true)
        dir_str = to ? "[Conn --> Main]" : "[Main ---> Conn]"
        raise ConnectionError, "#{dir_str} -- Cannot Transfer Cookies : Connection : #{conn_name} Doesn't Exist!"
    end

    def cookie_to_main( connection_name )
        #transfers cookies from connection name ----> main :agent connection
        return if !main_connection_exists?
        raise_cookie_error( connection_name ) if !connection_exists?( connection_name )
    end

    def cookie_from_main( connection_name )
        #transfers cookies from main connection to --> connection name
        return if !main_connection_exists?
        return if connection_name == :agent
        raise_cookie_error( connection_name, false ) if !connection_exists?( connection_name )

        info("[Connection] -- Transferring Main Cookies to Connection : #{connection_name.inspect}")
        num_cookies = send(:[], connection_name).load_cookies( main_connection.cur_uri, main_connection.cookies )
        info("[Connection] -- Transferred [ #{num_cookies} ] Cookies to Connection : #{connection_name.inspect}")
    end


    def is_fetch_call?( method )
        FetchMethods.include?( method )
    end

    def execute_connector_call( connection_name, method, args )

        #send the actual connection call to the connection here
        #determine if its a fetch call or just normal method
        #if its fetch call we wrap it in switch proxy retry code.
        if is_fetch_call?( method )
            execute_connector_fetch_call( connection_name, method, args )
        else
            execute_connector_normal_call( connection_name, method, args )
        end

    end

end