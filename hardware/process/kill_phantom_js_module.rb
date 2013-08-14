

module KillAllPhantom

    def kill_phantom_js()
        begin

           if defined?( PhantomJSEXE )
              process_name = File.basename( PhantomJSEXE )
              kill_process( process_name, true )
           else
              raise ProcessHardwareError, "Cannot Hard Kill PhantomJS!  No PhantomJSEXE const defined!"
           end

        rescue => err
           report_exception( ProcessHardwareError, err )
        end
    end
end
