

#basically retrieves new content
#and saves it into :temp variables for
#later retrieval.

class ArticleTagHandler

    include Enviornment
    include GlobalWrapper
    include ArticleSanitizerModule

    def initialize( tag, tag_args={} )

        @tag           = tag.to_sym
        @tag_args      = tag_args

        @fetcher_obj   = nil

        init_content()
        
    end

    def return_content()
        #returns the content we parsed based on the @tag we have.
        self[@tag]
    end

    def cleanup()
        self[:content] = nil if !self[:content].nil?
    end

    def raise_exception( msg )
        raise ContentError, msg
    end

    def init_fetcher_object()
        @fetcher_obj = case global_var( :content_location )
            when :ondisk ;  OnDiskFetcher.new
            when :dbase  ;  raise_exception( 'Dbase Content Fetching Not Implemented!' )
        else
            raise_exception( 'Cannot Determine Content Fetch Type Based on Global Setting : :content_location!' )
        end
    end

    def fetch_content()
        init_fetcher_object
        self[:content] = @fetcher_obj.fetch
    end

    def spin_content()
        self[:content] = Spinner.new.spin( self[:content] )
    end

    def init_content()

      begin

        fetch_content()
        spin_content()      #<---- will first validate spintax and
                            #<---- then spin content
        sanitize_content()  #<---- seperate aticle_title, and article_text

      rescue => err
          raise_exception( err.message )
      ensure
          cleanup()
      end

    end

end
