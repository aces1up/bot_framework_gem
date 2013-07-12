

class Thread

      def init_uuid()
          self[:uuid] = SecureRandom.uuid
      end

      def uuid()
          self[:uuid]
      end

      def has_var_mediator?()
          key?(:vars)
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
          self[:vars].add( var_hash, var_container, overwrite )
      end

      def teardown_thread_connections()
          return if !self[:conns]
          self[:conns].cleanup_all_connections
      end

end
