
class Auth

  @resolv = Resolv.new

  class << self

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

    def by_cookie(cookie)
      User.first({:name => cookie['login']})
    end

  end

end