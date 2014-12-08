module Packagecloud
  class Connection
    attr_reader :scheme, :host, :port

    def initialize(scheme="https", host="packagecloud.io", port="443")
      @scheme = scheme
      @host = host
      @port = port
    end
  end
end