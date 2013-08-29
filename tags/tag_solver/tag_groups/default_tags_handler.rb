

module DefaultTagHandler

    def truncate( tag_solved, num_words )
        tag_solved.truncate_words( num_words.to_i )
    end

    def escape_double_quotes( tag_solved, value )
        tag_solved.escape_double_quotes
    end
    
    def downcase( tag_solved, value )
        tag_solved.downcase
    end

    def upcase( tag_solved, value )
        tag_solved.upcase
    end
    
    def url_encode( tag_solved, value )
        Addressable::URI.escape( tag_solved )
    end

    def cgi_encode( tag_solved, value )
        CGI::escape( tag_solved )
    end


end
