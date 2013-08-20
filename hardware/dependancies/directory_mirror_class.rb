

# ensures The remote and local directory
# are mirrored.. ex no local files should exist
# unless they also exist in remote directory

class DirectoryMirror

    ExcludeDirs = [ 'win/', 'linux/', '32/', '64/' ]

    include Enviornment
    include LogHandler

    def initialize( local_dir, remote_url )

        @local_dir   = local_dir
        @remote_url  = remote_url

        @dir = HTMLDirectoryHelper.new
        @dir.open( @remote_url )

    end

    def file_no_checksum( filename )
        if filename.include?( '--' )
            ext       = File.extname( filename )
            file_part = filename.split('--').first
            "#{file_part}#{ext}"
        else
            filename
        end
    end


    def all_remote_files()
        #returns all remote files without checksums
        @r_files ||= @dir.all_files_with( @local_dir ).map{ |file|
            puts "getting remote files"
            no_checksum = file_no_checksum( file )
            ExcludeDirs.each do |exclude|
               no_checksum.gsub!( exclude, '' )
            end
            no_checksum
        }
        @r_files
    end

    def all_local_files( dir )
        @l_files ||= dir_files( dir, true )
        @l_files
    end

    def remove_empty_directories( dir )
        files = Dir.glob dir + '*/*'
        files.each do |dir_map|
          if dir_empty?( dir_map )
            info "[ Mirror ] Removing Empty Directory : #{dir_map}"
            FileUtils.rmdir dir_map
          end
        end
    end

    def mirror( dir )

        info("[ Mirror ] Mirroring Files from: #{@remote_url}")

        all_local_files( dir ).each do |file|

            if !all_remote_files.include?( file )
                info("[ Mirror ] Removing Local File: #{file}")
                File.delete( file )
            end

        end

        remove_empty_directories( dir )

    end
end
