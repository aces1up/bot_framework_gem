
require 'hardware/dependancies/http_uri_stats'

Exclude_directories    = [ '64', '32', 'win', 'linux', 'osx' ]
DownloadRetryInterval  = 5
MaxDownloadRetry       = 60  #<--- 5 minutes

class DependancyDownloader

    include Enviornment
    include LogHandler
    include HardwareHelper
    include SplashUpdateModule

    def initialize(dependancy_start_url, root_download_path, ignore_exclude=false)

        @start_url = dependancy_start_url  #<--- root_url of where we are downloading files from.
        @root_path = root_download_path    #<--- where we put the downloaded files

        @dir = HTMLDirectoryHelper.new
        @dir.open( dependancy_start_url )

        @ignore_exclude = ignore_exclude
        @retry = 0

    end

    def exclude_directory?( dir )
        return false if @ignore_exclude  #<--- force saying this is not an exclude directory
                                         #<--- if we are ignoring the exclude directories
                                         #<--- from the checksum rake task
        cleaned_dir = dir.chop if dir[-1,1] == '/'
        Exclude_directories.include?( cleaned_dir )
    end

    def has_os_directory?( dir_obj )
        dir_obj.directories.include?("#{os.to_s}/")
    end

    def directories( &block )

        current_directories = @dir.directories.dup
        current_directories.each do |dir|

            next if exclude_directory?(dir)

            @dir.cd(dir)
            yield @dir.current_dir, @dir.files, has_os_directory?(@dir)
            directories(&block)
        end

        @dir.cdup

    end

    def cleanup_download_error(filename)
        error_msg = "Unable to Download Dependancy: #{filename}.\nPlease Report this error on our WebSite: http://linkwheelbandit.com.\nRestart app to try downloading dependancies again.\nLinkWheel Bandit Trainer will now shutdown."
        del_file( filename )
        update_new( error_msg )
        
        java.lang.System.exit(0)
    end

    def report_retry(filename)
        retry_msg = "[Retry : #{@retry} / #{MaxDownloadRetry} ]"
        update_new( "Error Connecting to Server -- #{retry_msg} -- Retrying #{filename} in #{DownloadRetryInterval} Seconds" )
    end

    def do_retry?()
        @retry < MaxDownloadRetry
    end

    def handle_retry(file_handle, filename)
        begin file_handle.close if file_handle ; rescue ; end
        del_file(filename)

        @retry += 1
        report_retry(filename)
        sleep( DownloadRetryInterval ) if do_retry?
    end

    def download_file(remote_filename, local_filename)
        @retry = 0
        @has_download_error = false

        filename_no_checksum = Checksum.new(local_filename).extract_filename
        begin

          update_new( "Downloading Support File: [ #{filename_no_checksum} ]" )

          f = File.new(local_filename, "w")
              uri = URI.parse(remote_filename)
                  Net::HTTP.get_response_with_stats(uri) do |resp, bytes|
                    f.syswrite(bytes)
                
                    update( "[ #{resp.bytes_percent}% -- #{(resp.bytes_rate / 1024).to_i}/Kbs ] -- Downloading File: [ #{filename_no_checksum} ]" )
                  end

        rescue NativeException => err

            handle_retry(f, local_filename)   #<--- closes created file
                                              #<--- and runs sleep
            retry if do_retry?

            #if we get here we were unable to recover from download
            #so report error and shutdown app.
            @has_download_error = true

        rescue => err
          
            handle_retry(f, local_filename)   #<--- closes created file
                                              #<--- and runs sleep
            retry if do_retry?

            #if we get here we were unable to recover from download
            #so report error and shutdown app.
            @has_download_error = true

        ensure
            begin f.close if f ; rescue ; end
            cleanup_download_error( local_filename ) if @has_download_error  #<--- reports error and kills app.
                                                                             #<--- deletes file as well
        end
    end

    def download_os_specific_files( local_dir, remote_dir )
        #this will download os specific files based on OS and cpu Architechture
        
        os_remote_dir = "#{remote_dir}#{os.to_s}/#{arch_to_s}/"

        os_directory = HTMLDirectoryHelper.new
        os_directory.open( os_remote_dir )
        return if !os_directory.valid_directory?
        
        os_directory.files.each do |file|

            local_filename  =  "#{local_dir}#{file}"
            remote_filename =  "#{os_remote_dir}#{file}"

            handle_download( remote_filename, local_filename )

        end
    end
    
    def extract(filename)
        #extract file filename here ONLY if its a zip file
        return if File.extname( filename ) != '.zip'
        Extractor.new.decompress( filename )
    end

    def handle_download( remote, local )

        #run the checksum validator to determine if
        #we should download this file or not.
        checksum_validator = Checksum.new( local )

        return if !checksum_validator.download?()

        download_file( remote, local)

        local_filename = checksum_validator.save

        #checksum validator save will save/rename the
        #local file removing the checksum from the file
        #name..  the saved to disk file will be returned
        #as the result of the function.. if function returns
        #false there was an error processing it.
        extract( local_filename ) if local_filename != false
    end
    
    def download( is_repo=false )

        report_str = is_repo ? "Checking Repo Support Files: #{@start_url}" : "Checking Support Files..."
        update_new( report_str )

        directories do |dir, files, has_os_specific_files|
            #puts "processing dir: #{dir.inspect} -- Has Os Files?: #{has_os_specific_files.inspect}"
            local_dir = "#{@root_path}#{dir.gsub(@start_url, '')}"
            create_dir( local_dir )

            download_os_specific_files( local_dir, dir ) if has_os_specific_files

            files.each do |file|
                local_filename = "#{local_dir}#{file}"
                remote_filename = "#{dir}#{file}"

                handle_download( remote_filename, local_filename )
            end
        end

    end
end
