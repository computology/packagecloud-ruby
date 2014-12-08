module Packagecloud
  class Credentials
    attr_reader :username
    attr_reader :token

    def initialize(username, token)
      @username = username
      @token = token
    end
  end
end