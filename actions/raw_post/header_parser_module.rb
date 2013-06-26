

ExcludeHeaders = ['proxy-authorization', 'cookie', 'content-length']


module HeaderParser

    def convert_headers_to_hash()
        raw = @headers.map{ |header| header.split(':',2).map{|str| str.lstrip } }.flatten
        @headers = Hash[*raw]

        #sanitize headers that shouldn't be included
        @headers.delete_if{ |header, value| ExcludeHeaders.include?( header.downcase ) }
    end

    def solve_header_tags()
        header_str = solve_tag( @headers.join( RawPost::SplitDelimeter ) )
        @headers = header_str.split( RawPost::SplitDelimeter )
    end


    def parse_headers()
        solve_header_tags()
        convert_headers_to_hash()
    end

end