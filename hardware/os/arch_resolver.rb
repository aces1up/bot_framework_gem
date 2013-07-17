

require 'rbconfig'

module ArchResolver

    def bit_size()
        1.size * 8
    end

    def is_64?()
        bit_size == 64
    end

    def is_32?()
        bit_size == 32
    end

    def arch_to_s()
        case
            when is_64? ; '64'
            when is_32? ; '32'
        end
    end

end

