

module DefaultTagHandler

    def truncate( tag_solved, num_words )
        tag_solved.truncate_words( num_words.to_i )
    end

end
