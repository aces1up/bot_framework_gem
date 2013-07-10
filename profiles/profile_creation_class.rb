

class ProfileData
    #will generate a hash for easy loading
    #into our login_data :acct container
    #on new create account functions

    include Tags
    include TagSolverHelper

    attr_reader :profile

    def initialize()
        @profile = {}

        generate()
    end

    def get_profile()
        @profile
    end

    def random_password(size = 8)
        chars = (('a'..'z').to_a + ('0'..'9').to_a) - %w(i o 0 1 l 0)
        upcase_chars = ('A' .. 'Z').to_a
        password = "#{upcase_chars[rand(upcase_chars.length)]}"
        password += (1..size).collect{|a| chars[rand(chars.size)] }.join
        password
    end

    def get_profile_var( var )
        solve_tag( var, nil, true )
    end

    def generate

        username = "#{get_profile_var( :username )}#{rand(999)}"
        domain   = get_profile_var( :domain )
        email    = "#{username}@#{domain}"

        @profile = {
            :username       =>    username,
            :first_name     =>    get_profile_var( :first_name ),
            :last_name      =>    get_profile_var( :last_name ),
            :domain         =>    domain,
            :email          =>    email,
            :password       =>    random_password
        }
    end

end
