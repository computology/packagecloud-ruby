module Packagecloud
  class Connection
    attr_reader :scheme, :host, :port, :connect_timeout, :read_timeout, :write_timeout

    def initialize(scheme="https", host="packagecloud.io", port="443", options={})
      @scheme = scheme
      @host = host
      @port = port

      @connect_timeout = options[:connect_timeout] || 60
      @read_timeout = options[:read_timeout] || 60
      @write_timeout = options[:write_timeout] || 180
    end
  end
end
