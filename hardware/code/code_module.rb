
module CodeModule
  
    def init_salt()
        salt = rand(999999)
        GlobalSettings.instance.set_var( :salt, salt, true )
        salt
    end

    def salt_code()
        salt = GlobalSettings.instance.get_var( :salt )
        salt ||= init_salt
        salt
    end

    def raise_hardware_error( for_os )
        raise "Cannot Retrieve Hardware Code For #{for_os.to_s.capitalize}"
    end
  
    def hd_serial
        case os
            when :win   ;  `wmic DISKDRIVE GET SerialNumber`.strip_rn.strip_letters.remove_whitespace
             
            when :linux ;  raise_hardware_error( :linux )
        end
    end
    
    def bios_serial()
        case os
            when :win   ;  
                serial = `wmic bios get SerialNumber`
                serial.gsub('SerialNumber', '').strip_rn.remove_whitespace

            when :linux ;  raise_hardware_error( :linux )
        end
    end
    
    def get_code()
        "#{hd_serial}#{bios_serial}#{salt_code}"
    end


    def hardware_code()
        case os
            when :win   ; get_code

            when :linux ; raise_hardware_error( :linux )
        end
    end
end
