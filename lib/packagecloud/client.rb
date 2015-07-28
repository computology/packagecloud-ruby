require 'json/pure'
require 'mime'
require 'excon'
require 'packagecloud/result'
require 'packagecloud/connection'
require 'packagecloud/version'

module Packagecloud
  SUPPORTED_EXTENSIONS = ["deb", "rpm", "gem", "dsc"]

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

    def initialize(credentials, user_agent="default", connection=Connection.new)
      @credentials = credentials
      @connection = connection
      @user_agent = user_agent

      scheme = self.connection.scheme
      host = self.connection.host
      port = self.connection.port
      token = self.credentials.token

      @excon = Excon.new("#{scheme}://#{token}@#{host}:#{port}")
      assert_valid_credentials
      assert_compatible_version
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

    def package_contents(repo, package)
      assert_valid_repo_name(repo)
      url = "/api/v1/repos/#{username}/#{repo}/packages/contents.json"

      mixed_msg = MIME::Multipart::FormData.new

      pkg_data = MIME::Application.new(package.file.read)
      pkg_data.headers.set('Content-Transfer-Encoding', 'binary')
      mixed_msg.add(pkg_data, "package[package_file]", package.filename)

      response = multipart_post(url, mixed_msg)

      parsed_json_result(response)
    end

    def list_packages(repo)
      assert_valid_repo_name(repo)
      response = get("/api/v1/repos/#{username}/#{repo}/packages.json")
      parsed_json_result(response)
    end

    def put_package(repo, package)
      assert_valid_repo_name(repo)

      url = "/api/v1/repos/#{username}/#{repo}/packages.json"

      mixed_msg = MIME::Multipart::FormData.new

      if package.distro_version_id != nil
        mixed_msg.add(MIME::Text.new(package.distro_version_id), "package[distro_version_id]")
      end

      pkg_data = MIME::Application.new(package.file.read)
      pkg_data.headers.set('Content-Transfer-Encoding', 'binary')
      mixed_msg.add(pkg_data, "package[package_file]", package.filename)

      package.source_files.each do |filename, io|
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
        all_distros = deb_distros.merge(rpm_distros)
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

      def assert_compatible_version
        result = gem_version
        if result.succeeded
          if result.response["minor"] != MINOR_VERSION
            raise GemOutOfDateException.new("This library is out of date, please update it!")
          elsif result.response["patch"].to_i > PATCH_VERSION.to_i
            puts "[WARNING] There's a newer version of the packagecloud-ruby library. Update as soon as possible!"
          end
        elsif result.response.downcase.include?('unauthenticated')
          raise UnauthenticatedException.new
        else
          raise "Unable to get gem version from API: #{result.response}"
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
        @excon.request(request_params)
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
