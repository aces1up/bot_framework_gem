

module MySqlStartup

    def mysql_admin_exists?()
        File.exist?("#{$working_directory}mysql/bin/mysqladmin.exe")
    end

    def mysql_started?()
        process_started?( ['lb-mysqld', 'lb-mysqld64.exe' ] )
    end

    def get_mysql_exe()
        is_64? ? "lb-mysqld64.exe" : "lb-mysqld.exe"
    end

    def start_mysql()
        mysql_exe = get_mysql_exe
        execute_string = "#{$working_directory}mysql/bin/#{mysql_exe} --defaults-file=#{$working_directory}mysql/my.ini --port 3320"
        execute_process(execute_string)

        wait_for_process( mysql_exe, true )
    end
    
    def kill_mysql_safe_way()
        puts "killing mysql the safe way!"
        mysql_exe = "mysqladmin.exe"
        execute_string = "#{$working_directory}mysql/bin/#{mysql_exe} -u root shutdown"
        execute_process( execute_string )
    end

    def kill_mysql_badway()
        puts "killing mysql the bad way!"
        kill_process( get_mysql_exe )
    end

    def kill_mysql()

        return if !mysql_started?
        mysql_admin_exists?() ? kill_mysql_safe_way() : kill_mysql_badway()
        wait_for_process( get_mysql_exe, false, 100, 0.1 )

    end

    def get_ini_contents(filename)
        contents = ''
        File.open(filename).each do |line| contents << line end
        contents
    end

    def save_ini_file(filename, contents)
        File.open(filename, 'w') {|f| f.write(contents) }
    end
    
    def init_mysql_ini()
        ini_file = "#{$working_directory}mysql/my.ini"
        return if !File.exists?(ini_file) 
        contents = get_ini_contents(ini_file)
      
        #sub out our directories if they haven't been initialized
        if contents.include?('~~~base_dir') then
            contents.gsub!('~~~base_dir', "#{$working_directory}mysql")
            contents.gsub!('~~~log_dir', "#{$working_directory}logs/mysql.log")
            contents.gsub!('~~~data_dir', "#{$working_directory}mysql/data")
            
            #write the file back
            save_ini_file(ini_file, contents)
        end
    end

    def run_mysql_startup()

        if mysql_started? then kill_mysql() end

        init_mysql_ini()
        start_mysql()

    end
end
