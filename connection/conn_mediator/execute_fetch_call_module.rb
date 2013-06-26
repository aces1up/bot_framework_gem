
module ExecuteConnectorFetchCall

    def increment_connection_request_count( connection_name, method )
        return if !FetchMethods.include?( method )
        @conns_count[ connection_name ] ||= 0
        @conns_count[ connection_name ] +=  1
    end

    def handle_switch_proxy_on_fail( conn_handle, retry_count, max_retries )
        info("Retrying Connection [ #{retry_count} / #{max_retries} ] -- Switching Proxy...")
        conn_handle.switch_proxy()
    end

    def execute_connector_fetch_call( connection_name, method, args )

        begin

            debug("Doing Connection Fetch Call : [Connection Name: #{connection_name.inspect}] -- [Method: #{method.inspect}]")
            #increment our connect request count for the connection name
            increment_connection_request_count( connection_name, method )

            conn_handle = self[ connection_name ]
            result = conn_handle.send( method, *args )

            result

        rescue Timeout::Error => err


        rescue => error_obj

            retry_count ||= 0
            retry_count += 1

            if retry_count > MaxConnectRetries
               #we have met max retries so raise a DeadSite Exception here.
               raise ConnectionError, error_obj.message
            else
               #run the retry code here, but make sure we switch the connection
               #proxy first before attempting retry.
               handle_switch_proxy_on_fail( conn_handle, retry_count, MaxConnectRetries )
               retry

            end

        end
    end

end
