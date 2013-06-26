

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

      def get_var( attr )
          raise EnviornmentError, "Cannot Retrieve Enviornment Variable Via Thread : #{attr.inspect} -- No Var Mediator Set for Thread!" if !has_var_mediator?
          self[:vars][attr]
      end

      def set_var( var_hash, var_container=:temp, overwrite=true )
          raise EnviornmentError, "Cannot Add via Thread Enviornment Variable -- No Var Mediator Set for Thread!" if !has_var_mediator?
          self[:vars].add( var_hash, var_container, overwrite )
      end

end
