

module FunctionHelperModule

    def return_error(err_obj, do_raise)
        do_raise ? raise : err_obj.message
    end

    def wrap_lambda( lam_block, max_retries, name, do_raise=false )

        retry_count = 0

        info "Running Function Lambda -- #{name} -- Retries: #{max_retries}"

        begin

          lam_block.call
          retry_count = 0  #<--- we had a success
                           #<--- so reset our retry_count

          nil              #<--- return nil meaning we didn't have an error
                           #<--- here

        rescue LoginError => err
           err.report
           return_error( err, do_raise )
           
        rescue GeneralAppException => err

           retry_count += 1
           if retry_count < max_retries
              error "[Error Retry -- [ #{retry_count} / #{max_retries} ] -- #{err.message}"
              retry
           else
               err.report
               return_error( err, do_raise )
           end

        rescue => err
            excep = FatalAppError.new( err.message )
            excep.set_backtrace( caller )
            excep.report

            return_error( excep, do_raise )
        end

    end

    def wrap_lambdas( lam_blocks, max_retries, name, do_raise=false )

        lam_blocks = [lam_blocks] if !lam_blocks.is_a?( Array )

        lam_blocks.each do |lam|
            lam_result = call_lambda( lam, max_retries, name, do_raise )
            return lam_result if lam_result
        end
    end
end
