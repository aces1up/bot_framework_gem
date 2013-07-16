

class OnDiskFetcher < ContentFetcher

    def has_content?()
        !dir_empty?( ContentDir )
    end

    def fetch()
        raise_exception( 'No OnDisk Content Found!' ) if !has_content?

        load_file = random_file_dir( ContentDir )
        file_contents( load_file )
    end

end
