

module ProcessHelper

   def execute_process(execute_string)
       createprocess = Win32API.new('kernel32','CreateProcess', 'LPLLLLLLPP', 'I')

       startinfo = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
       startinfo = startinfo.pack('LLLLLLLLLLLLSSLLLL')
       procinfo  = [0,0,0,0].pack('LLLL')

       createprocess.call( 0, execute_string, 0, 0, 0, 0, 0, 0, startinfo, procinfo )
   end

   def kill_process_win( process_name, kill_all=false )
       kill_all_str = kill_all ? '/t' : ''
       `taskkill /im #{process_name} /f #{kill_all_str} >nul 2>&1`
   end

   def kill_process( process_name, kill_all=false )
       case os
          when :win    ;   kill_process_win( process_name, kill_all )
          when :linux  ;   raise ProcessHardwareError, "Cannot kill Process on Linux, Not Implemented!"
       end
   end


   def process_started_win?( process_exe )
       command = "wmic process where(name=\"#{process_exe}\") get commandline"
       puts "running process command: #{command}"
       result = %x[#{command} 2>&1]
       result.include?('No Instance') ? false : true
   end

   def process_started?( process_exe )
       case os
          when :win    ;   [process_exe].flatten.any?{ |proc_exe| process_started_win?( proc_exe ) }
          when :linux  ;   raise ProcessHardwareError, "Cannot Check Process Started on Linux, Not Implemented!"
       end
   end

   def wait_for_process( process_exe, wait_for_start=true, retries=10, interval=0.1 )

       retry_count = 0
       while retry_count <= retries do
          case wait_for_start
             when true
                return true if process_started?(process_exe)
             when false
                return true if !process_started?(process_exe)
          end
          #puts "Wait For Process -- [Process: #{process_exe.inspect}] -- [Retry: #{retry_count} / #{retries}] -- [Wait_for_start: #{wait_for_start.inspect}]"
          retry_count += 1
          sleep(interval)
       end

       false
   end
end
