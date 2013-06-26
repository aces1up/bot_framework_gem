

module FileHandlingTags

    def get_random_file_line( filename )

        line = nil

        File.open(filename, "r") do |file|

             line = nil
             retry_count = 0
             max_retry = 5

             while ( line.nil? and !valid_url?( line ) and retry_count < max_retry )

                  line = rand_file_line( filename, file )
                  
                  retry_count += 1
                  sleep(0.1)
             end
        end

        line
    end

    def random_file_url( filename )
        begin

          if File.exists?(filename)

             url = get_random_file_line(filename)
             
             if url.nil? or url.empty?
                raise TagSolverError, "Unable to Retrieve Valid Url From File : #{filename}"
             else
                url
             end

          else
             raise TagSolverError, "File Does not Exists... Cannot get Random File URL using : #{filename}"
          end

        end
    end

    def find_file( filename )
        #if full path is not specified for a file when being used
        #in a tag, we then search for it in using a Glob on the Working
        #directory to search recursively for it.
        search_glob = "#{WorkingDirectory}**/#{filename}"
        found = Dir.glob( search_glob )
        found.empty? ? nil : found.first
    end

    def resolve_file( filename )
        filename = @tag_args[:file]
        filename = is_full_path?( filename ) ? filename : find_file( filename )
        raise TagSolverError, "Unable to get Rand File Line, cannot Resolve : #{@tag_args[:file]} Location..." if filename.nil?

        filename
    end

    def rand_file()

        case @tag_args[:file]
            when 'random_platform_site' ;
        else
            filename = resolve_file( @tag_args[:file] )
            rand_file_line( filename )
        end
   
    end
end
