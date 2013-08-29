EOL = "\015\012"

class Part < Struct.new(:name, :body, :filename, :content_disposition, :content_type, :encoding)
  def initialize(*args)
    if args.flatten.first.is_a? Hash
      from_hash(args.flatten.first)
    elsif args.length > 0
      from_args(*args)
    end
  end

  def from_hash(hash)
    hash.each_pair do |k, v|
      if k.to_s == 'body' && (v.is_a?(File) || v.is_a?(Tempfile))
        self[k] = v.read
        self['filename'] = File.basename(v.path)
      else
        self[k] = v
      end
    end
  end

  def from_args(name, body, filename=nil)
    self.from_hash(:name => name, :body => body, :filename => filename)
  end

  def header
    header = ""
    if content_disposition || name
      header << "Content-Disposition: #{content_disposition || 'form-data'}"
      header << "; name=\"#{name}\"" if name && !content_disposition
      header << "; filename=\"#{filename}\"" if filename && !content_disposition
      header << "\r\n"
    end
    header << "Content-Type: #{content_type}\r\n" if content_type
    header << "Content-Transfer-Encoding: #{encoding}\r\n" if encoding
    header
  end

  # TODO: Implement encodings
  def encoded_body
    case encoding
    when nil
      body
    else
      raise "Encodings have not been implemented"
    end
  end

  def to_s
    "#{header}\r\n#{encoded_body}"
  end
end



class MultipartBody
  attr_accessor :parts, :boundary

  def initialize(parts = nil, boundary = nil)
    @parts = []
	#@boundry_code = rand(000000000000)
    #@boundary = boundary || "-----------------------------#{@boundry_code}"
	@boundary = boundary
	@boundary ||= "----234092834029834092830498"

    if parts.is_a? Hash
      @parts = parts.map {|name, body| Part.new(:name => name, :body => body) }
    elsif parts.is_a?(Array) && parts.first.is_a?(Part)
      @parts = parts
    end

    self
  end

  def self.from_hash(parts_hash)
    multipart = self.new(parts_hash)
  end

  def to_s
    #output = "--#{@boundary}#{EOL}"
    body = @parts.join("--#{@boundary}#{EOL}")
    body = "--#{@boundary}#{EOL}" + body + "--#{@boundary}--" + EOL
	body
  end
end


