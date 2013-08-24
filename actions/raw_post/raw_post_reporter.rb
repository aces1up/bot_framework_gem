

module RawPostReporter

    def report_headers
        info  "[ Headers ] : "
        @headers.each do |header, val| info " [ #{header} ] -- #{val} " end
    end

    def report_post_body()
        info "[ Sumbit Body ]:"
        info @post_body
    end

    def report_post_info
        info  "Submitting Raw Request"
        info  "[ Method: #{@method.to_s.upcase} ]"
        info  "[ URL: #{@url} ]"
        info  "[ Content-Type: #{@content_type.to_s.capitalize} ]"

        report_headers
        report_post_body
    end
end
