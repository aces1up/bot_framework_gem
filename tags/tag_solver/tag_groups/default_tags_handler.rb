

module DefaultTagHandler

    def truncate( tag_solved, num_words )
        alert_pop("Truncate")
        tag_solved.truncate_words( num_words.to_i )
    end

end
