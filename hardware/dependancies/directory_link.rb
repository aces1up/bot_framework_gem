

class DirectoryLink
    attr_reader :href, :text

    def initialize(node)
        @href = node['href']
        @text = node.inner_text
    end

    def uri
        @href && URI.parse(URI.encode(@href))
    end
end
