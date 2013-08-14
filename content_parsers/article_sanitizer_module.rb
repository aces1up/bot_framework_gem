

module ArticleSanitizerModule

    def split_title_and_text()

        text = @content

        lines = text.split( /\n|<br>|<br \/>/ )

        title = lines.delete( lines.find{ |line| !line.empty? } )

        first_non_empty_index = lines.find_index{ |line| !line.empty? }

        if first_non_empty_index != 0
            lines[0..first_non_empty_index-1] = nil
            lines.compact!
        end

        body = lines.join("\n")

        [ title, body ]

    end

    def sanitize_content()
        split_title_and_text()
    end

end
