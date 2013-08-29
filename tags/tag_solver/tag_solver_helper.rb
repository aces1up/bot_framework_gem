

module TagSolverHelper

    def solve_multiple_tags(tags, delimiter=nil)
        #will solve multiple tags ex: [:fist_name, :last_name]
        #and return that as full string with delimiter if specified.

        delimiter ||= ' '
        tags_sanitized = tags.map{ |tag| tag.to_s.include?('%') ? tag : "%#{tag.to_s}%" }
        tags_sanitized.map{|tag|  TagSolver.new( tag ).parse_tag  }.join( delimiter )

    end

    def solve_tag( tag, add_tag_delimiter=false)

        tag = "~~#{tag.to_s}~~" if add_tag_delimiter

        TagSolver.new.parse_tag( tag.to_s.dup )

    end
end
