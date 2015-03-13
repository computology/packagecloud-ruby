module Packagecloud
  class Credentials
    attr_reader :username
    attr_reader :token

    def initialize(username, token)
      @username = username
      @token = token
      if @username.include?("@")
        raise InvalidUsernameException.new("Sorry, looks like you may have " \
                                           "tried to use an email address " \
                                           "instead of your packagecloud.io " \
                                           "username. Please use your " \
                                           "username instead!")
      end
    end
  end
end
