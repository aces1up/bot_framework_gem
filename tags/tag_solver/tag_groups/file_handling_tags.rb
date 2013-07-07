

module FileHandlingTags

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

    def random_line_from_file()

        case @tag_args[:file]
            when 'random_platform_site' ;
        else
            filename = resolve_file( @tag_args[:file] )
            rand_file_line( filename )
        end
   
    end
end
