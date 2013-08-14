

class Thread

      def init_uuid()
          self[:uuid] = SecureRandom.uuid
      end

      def uuid()
          self[:uuid]
      end

      def clear_uuid()
          self[:uuid] = nil
      end

      def has_var_mediator?()
          key?(:vars)
      end

      def has_connection_mediator?()
          key?(:conns)
      end

      def connection_mediator()
          self[:conns]
      end

      def connection_handle( conn_name=:agent )
          connection_mediator[conn_name]
      end

      def container_data( container )
          raise EnviornmentError, "Cannot Get Container Data for: #{container.inspect} -- No Var Mediator Set for Thread!" if !has_var_mediator?
          self[:vars].container_data( container )
      end

      def container_empty?(container)
          raise EnviornmentError, "Cannot Check if Container Empty for: #{container.inspect} -- No Var Mediator Set for Thread!" if !has_var_mediator?
          self[:vars].container_empty?( container )
      end

      def get_var( attr )
          raise EnviornmentError, "Cannot Retrieve Enviornment Variable Via Thread : #{attr.inspect} -- No Var Mediator Set for Thread!" if !has_var_mediator?
          self[:vars][attr]
      end

      def set_var( var_hash, var_container=:temp, overwrite=true )
          raise EnviornmentError, "Cannot Add via Thread Enviornment Variable -- No Var Mediator Set for Thread!" if !has_var_mediator?
          return if self[:vars].nil?
          self[:vars].add( var_hash, var_container, overwrite )
      end

      def set_status_terminated()
          set_var( { :status => :terminated }, :site, true )
      end

      def teardown_thread_connections()
          return if !self[:conns]
          self[:conns].cleanup_all_connections
      end
      
      def teardown_vars()
          return if !self[:vars]
          self[:vars] = nil
      end

      def teardown()
          teardown_thread_connections
          teardown_vars
          clear_uuid
      end

end
