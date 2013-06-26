

class Spinner
    SpinRegex = /{[^{}]+?}/
    MaxSpinLevels = 25

    def initialize()
        @level_count = 0
    end

    def rand_match(text)
        arr = text.split('|')
        arr[ rand(arr.length) ]
    end

    def complete?(text)
        @level_count += 1
        return true if @level_count >= MaxSpinLevels
        (text =~ SpinRegex).nil?
    end

    def spin(orig_text)

      text = orig_text.dup

      while !complete?(text) do
          text.gsub!(SpinRegex) do |match|
            match.slice!(0) ; match.chop!  #<----  delete the first and last { } braces
            match = rand_match(match)
          end
      end

      text

    end

end

