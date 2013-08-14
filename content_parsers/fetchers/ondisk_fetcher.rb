

class OnDiskFetcher < ContentFetcher

    def has_content?()
        !dir_empty?( ContentDir )
    end

    def fetch()

        raise_exception( 'No OnDisk Content Found!' ) if !has_content?

        load_file = random_file_dir( ContentDir )
        @content = file_contents_utf8( load_file )

        spin_content

        sanitize_content()  #<---- seperate aticle_title, and article_text

    end

end
