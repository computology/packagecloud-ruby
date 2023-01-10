require 'json'
require 'mime'
require 'excon'
require 'packagecloud/result'
require 'packagecloud/connection'
require 'packagecloud/version'

module Packagecloud
  SUPPORTED_EXTENSIONS = ["deb", "dsc", "gem", "rpm", "whl", "zip", "egg", "egg-info", "tar", "bz2", "Z", "gz", "tgz"]

  class UnauthenticatedException < StandardError
    attr_reader :object

    def initialize(object = nil)
      @object = object
    end
  end

  class GemOutOfDateException < StandardError
    attr_reader :object

    def initialize(object = nil)
      @object = object
    end
  end

  class InvalidRepoNameException < StandardError
    attr_reader :object

    def initialize(object = nil)
      @object = object
    end
  end

  class InvalidUsernameException < StandardError
    attr_reader :object

    def initialize(object = nil)
      @object = object
    end
  end

  class Client
    attr_reader :connection
    attr_reader :credentials

    def initialize(credentials, user_agent="packagecloud-ruby #{Packagecloud::VERSION}", connection=Connection.new)
      @credentials = credentials
      @connection = connection
      @user_agent = user_agent

      scheme = self.connection.scheme
      host = self.connection.host
      port = self.connection.port
      token = self.credentials.token

      @excon = Excon.new("#{scheme}://#{token}@#{host}:#{port}", :connect_timeout => @connection.connect_timeout)
      assert_valid_credentials
    end

    def distributions
      response = get("/api/v1/distributions.json")
      parsed_json_result(response)
    end

    def repositories
      response = get("/api/v1/repos.json")
      parsed_json_result(response)
    end

    def repository(repo)
      assert_valid_repo_name(repo)
      response = get("/api/v1/repos/#{username}/#{repo}.json")
      parsed_json_result(response)
    end

    def gem_version
      response = get("/api/v1/gem_version.json")
      parsed_json_result(response)
    end

    def create_repository(repo, private=false)
      assert_valid_repo_name(repo)
      privacy = private ? 1 : 0
      body = { "repository" => { "name" => repo, "private" => privacy.to_s } }
      response = post("/api/v1/repos.json", body.to_json)
      parsed_json_result(response)
    end

    def package_contents(repo, package, distro_version_id=nil)
      assert_valid_repo_name(repo)
      if distro_version_id.nil?
        raise "No distribution supplied for package_contents!"
      end

      url = "/api/v1/repos/#{username}/#{repo}/packages/contents.json"

      mixed_msg = MIME::Multipart::FormData.new

      package.file.rewind
      pkg_data = MIME::Application.new(package.file.read)
      pkg_data.headers.set('Content-Transfer-Encoding', 'binary')
      mixed_msg.add(pkg_data, "package[package_file]", package.filename)

      if distro_version_id.is_a? String
        distro_version = find_distribution_id(distro_version_id)
        raise "Cannot find distribution: #{distro_version_id}" if distro_version.nil?
        mixed_msg.add(MIME::Text.new(distro_version), "package[distro_version_id]")
      else
        mixed_msg.add(MIME::Text.new(distro_version_id), "package[distro_version_id]")
      end

      response = multipart_post(url, mixed_msg)

      parsed_json_result(response)
    end

    def list_packages(repo)
      assert_valid_repo_name(repo)
      response = get("/api/v1/repos/#{username}/#{repo}/packages.json")
      parsed_json_result(response)
    end

    def delete_package(repo, distro, distro_release, package_filename)
      assert_valid_repo_name(repo)
      url = "/api/v1/repos/#{username}/#{repo}/#{distro}/#{distro_release}/#{package_filename}"
      response = delete(url)
      parsed_json_result(response)
    end

    def put_package(repo, package, distro_version_id=nil)
      assert_valid_repo_name(repo)

      url = "/api/v1/repos/#{username}/#{repo}/packages.json"

      mixed_msg = MIME::Multipart::FormData.new

      if distro_version_id != nil
        if distro_version_id.is_a? String
          distro_version = find_distribution_id(distro_version_id)
          raise "Cannot find distribution: #{distro_version_id}" if distro_version.nil?
          mixed_msg.add(MIME::Text.new(distro_version), "package[distro_version_id]")
        else
          mixed_msg.add(MIME::Text.new(distro_version_id), "package[distro_version_id]")
        end
      end

      package.file.rewind
      pkg_data = MIME::Application.new(package.file.read)
      pkg_data.headers.set('Content-Transfer-Encoding', 'binary')
      mixed_msg.add(pkg_data, "package[package_file]", package.filename)

      package.source_files.each do |filename, io|
        io.rewind
        src_pkg_data = MIME::Application.new(io.read)
        src_pkg_data.headers.set('Content-Transfer-Encoding', 'binary')
        mixed_msg.add(src_pkg_data, "package[source_files][]", filename)
      end

      response = multipart_post(url, mixed_msg)

      prepare_result(response) { |result| result.response = "" }
    end

    def find_distribution_id(distro_query)
      distros = distributions
      if distros.succeeded
        deb_distros = distro_map distros.response["deb"]
        rpm_distros = distro_map distros.response["rpm"]
        py_distros = distro_map distros.response["py"]
        node_distros = distro_map distros.response["node"]
        all_distros = deb_distros.merge(rpm_distros).merge(py_distros).merge(node_distros)
        result = all_distros.select { |distro, id| distro.include?(distro_query) }
        if result.size > 1
          keys = result.map { |x| x.first }.join(' ')
          raise ArgumentError, "'#{distro_query}' is ambiguous, did you mean: #{keys}?"
        elsif result.size == 1
          result.first[1] # [["ubuntu/breezy", 1]]
        else
          nil
        end
      end
    end

    def create_read_tokens(repo, master_token_id, read_token_name)
      assert_valid_repo_name(repo)
      url = "/api/v1/repos/#{username}/#{repo}/master_tokens/#{master_token_id}/read_tokens.json"
      response = post(url, "read_token[name]=#{read_token_name}", "application/x-www-form-urlencoded")
      parsed_json_result(response)
    end

    def delete_read_token(repo, master_token_id, read_token_id)
      assert_valid_repo_name(repo)
      url = "/api/v1/repos/#{username}/#{repo}/master_tokens/#{master_token_id}/read_tokens/#{read_token_id}"
      response = delete(url)
      Result.new.tap do |result|
        result.succeeded = (response.status == 204)
      end
    end

    def list_read_tokens(repo, master_token_id)
      assert_valid_repo_name(repo)
      response = get("/api/v1/repos/#{username}/#{repo}/master_tokens/#{master_token_id}/read_tokens.json")
      parsed_json_result(response)
    end

    private
      def assert_valid_repo_name(repo)
        if repo.include?("/")
          raise InvalidRepoNameException.new("The repo name: #{repo} is " \
                                             "invalid. It looks like you are " \
                                             "using the fully qualified name " \
                                             "(fqname) instead of just the " \
                                             "repo name. Please try again.")
        end
      end

      def assert_valid_credentials
        result = distributions
        if result.succeeded == false && result.response.downcase.include?('unauthenticated')
          raise UnauthenticatedException
        end
      end

      def distro_map(distros)
        result = {}
        distros.each do |distro|
          name = distro["index_name"]
          distro["versions"].each do |version|
            version_name = version["index_name"]
            key = "#{name}/#{version_name}"
            result[key] = version["id"]
          end
        end
        result
      end

      def user_agent
        "packagecloud-ruby #{VERSION}/#{@user_agent}"
      end

      def multipart_post(url, mixed_msg)
        boundary = mixed_msg.boundary
        content_type = "multipart/form-data; boundary=#{boundary}"
        body = mixed_msg.to_s
        post(url, body, content_type)
      end

      def post(url, body, content_type="application/json")
        request(url, :post, body, content_type)
      end

      def get(url)
        request(url, :get)
      end

      def delete(url)
        request(url, 'DELETE')
      end

      def username
        self.credentials.username
      end

      def request(url, method=:get, body=nil, content_type=nil)
        headers = { "User-Agent" => user_agent }
        if content_type != nil
          headers.merge!({ "Content-Type" => content_type })
        end
        request_params = { :method => method, :path => url, :headers => headers }
        if body != nil
          request_params.merge!({ :body => body })
        end

        @excon.request(request_params.merge({:read_timeout => connection.read_timeout, :write_timeout => connection.write_timeout }))
      end

      # returns the parsed body of a successful result
      def parsed_json_result(response)
        prepare_result(response) { |result| result.response = JSON.parse(response.data[:body]) }
      end

      def prepare_result(response)
        result = Result.new
        if response.status == 201 || response.status == 200
          result.succeeded = true
          yield result
        else
          result.response = response.data[:body]
          result.succeeded = false
        end
        result
      end

  end
end
