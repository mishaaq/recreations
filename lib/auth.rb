require 'active_support/hash_with_indifferent_access'

class Auth

  @resolv = Resolv.new
  @digestor = Digest::SHA1.new
  @variables = HashWithIndifferentAccess.new(YAML.load_file(Padrino.root('config/config.yml'))['variables'])

  class << self

    # DEPRECATED
    def by_ip(ip)
      current_user = User.first_or_new({:name => ip})
      unless current_user.saved?
        begin
          display_name = @resolv.getname(ip).split('.').first
        rescue Resolv::ResolvError => e
          display_name = current_user.name
        end
        current_user.display_name = display_name
        unless current_user.save
          raise Exception.new("Could not save user.")
        end
      end
      current_user
    end

    # DEPRECATED
    def by_cookie(cookie)
      User.first({:name => cookie['login']})
    end

    def by_token(cookie)
      cookie['token'] && User.first({:auth_token => cookie['token']})
    end

    def generate_token(input)
      @digestor.hexdigest(@variables[:token_salt] + input)
    end
  end

end