
module ExecuteConnectorNormalCall

    def execute_connector_normal_call( connection_name, method, args )

        begin

            #info("Doing Normal Connection  Call : [Connection Name: #{connection_name.inspect}] -- [Method: #{method.inspect}]")

            conn_handle = self[ connection_name ]
            conn_handle.send( method, *args )

        rescue => err
            raise FatalConnectionError, err.message
        end

    end
end
