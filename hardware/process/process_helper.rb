

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

   def kill_process_now( process_exe, process_multiple=false )
        wmi = WIN32OLE.connect("winmgmts://")
        processes = wmi.ExecQuery("select * from win32_process")
        #puts("#{processes.inspect}")
        for process in processes do
          #puts "Name: #{process.Name}"
          if process_exe.is_a?(Integer)
              next if process.ProcessId != process_exe
          else
              next if !process.name.include?( process_exe )
          end
          #pid = process.ProcessId
          Kernel.puts "killing process: #{process.ProcessId.inspect}"
          process.Terminate
          return if !process_multiple
        end
   end

   def process_pids(process_exe)
      #returns an array of all pids matching
      #process_exe string
      pids = []

      wmi = WIN32OLE.connect("winmgmts://")
        processes = wmi.ExecQuery("select * from win32_process")

        for process in processes do
            next if !process.name.include?(process_exe)
            pids.push process.ProcessId
        end

        pids
   end

   def process_started?(process_exe)
      wmi = WIN32OLE.connect("winmgmts://")
      processes = wmi.ExecQuery("select * from win32_process")
      #puts("#{processes.inspect}")
      for process in processes do
        #return true if process.name.include?(process_exe)
        if process_exe.is_a?(Integer) #<--- if Integer its the process PID we want to look for
            return true if process.ProcessId == process_exe
        else
            return true if process.name.include?(process_exe)
        end

      end

      false
   end

   def wait_for_process(process_exe, wait_for_start=true, retries=10, interval=0.1)
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
