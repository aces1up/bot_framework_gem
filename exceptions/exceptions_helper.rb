

module ExceptionHelper

     def report_exception( klass, err )
          err_new = klass.new( err.message )
          err_new.set_backtrace( err.backtrace )
          err_new.report
     end

     def report_fatal( err )
         report_exception( FatalAppError, err )
     end

end
