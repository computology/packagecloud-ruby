require 'spec_helper'
require 'excon'
require 'packagecloud_server'
require 'packagecloud'
require 'webrick'

describe Packagecloud do

  include Packagecloud

  before(:all) do
    @server = Thread.start do
      server = WEBrick::HTTPServer.new(:Port => 8000)
      server.mount "/", PackagecloudServer
      trap "INT" do
        server.shutdown
      end
      server.start
    end

    credentials = Credentials.new("joedamato", "test_token")
    connection = Connection.new("http", "localhost", 8000)

    @client = Client.new(credentials, "test_client", connection)
  end

  it "should have a VERSION constant" do
    subject.const_get('VERSION').should_not be_empty
  end

  it "GET api/v1/distributions.json" do
    distros = @client.distributions
    expect(distros.succeeded).to be_truthy

    deb = distros.response["deb"]
    dsc = distros.response["dsc"]
    rpm = distros.response["rpm"]

    expect(deb).not_to be_empty
    expect(dsc).not_to be_empty
    expect(rpm).not_to be_empty
  end

  it "POST debian package /api/v1/repos/joedamato/test_repo/packages.json" do
    deb = File.dirname(__FILE__) + '/fixtures/libampsharp2.0-cil_2.0.4-1_all.deb'
    size = File.size(deb)
    package = Package.new(open(deb), 22)

    result = @client.put_package("test_repo", package)
    expect(result.succeeded).to be_truthy

    #assert content type is set correctly
    expect($request.content_type).to include("boundary=")
    expect($request.content_type).to include("multipart/form-data")

    # assert body is at least bigger than fixture file
    expect($request.content_length > size).to be_truthy
  end

  it "POST source package /api/v1/repos/joedamato/test_repo/packages.json" do
    dsc = File.dirname(__FILE__) + '/fixtures/natty_dsc/jake_1.0-7.dsc'
    jake_orig = File.dirname(__FILE__) + '/fixtures/natty_dsc/jake_1.0.orig.tar.bz2'
    jake_debian = File.dirname(__FILE__) + '/fixtures/natty_dsc/jake_1.0-7.debian.tar.gz'

    source_packages = { "jake_1.0.orig.tar.bz2" => open(jake_orig),
                        "jake_1.0-7.debian.tar.gz" => open(jake_debian),}

    dsc_size = File.size(dsc)
    jake_orig_size = File.size(jake_orig)
    jake_debian_size = File.size(jake_debian)
    combined_size = dsc_size + jake_orig_size + jake_debian_size

    #TODO consider opening IO objects automatically for paths
    package = Package.new(open(dsc), 22, source_packages)

    result = @client.put_package("test_repo", package)
    expect(result.succeeded).to be_truthy

    #assert content type is set correctly
    expect($request.content_type).to include("boundary=")
    expect($request.content_type).to include("multipart/form-data")

    # assert body is at least bigger than fixture file
    expect($request.content_length > combined_size).to be_truthy
  end

  it "POST /api/v1/repos/joedamato/test_repo/packages/contents.json" do
    dsc = File.dirname(__FILE__) + '/fixtures/natty_dsc/jake_1.0-7.dsc'
    size = File.size(dsc)
    package = Package.new(open(dsc))

    result = @client.package_contents("test_repo", package)
    expect(result.succeeded).to be_truthy
    expect(result.response["files"]).not_to be_empty

    #assert content type is set correctly
    expect($request.content_type).to include("boundary=")
    expect($request.content_type).to include("multipart/form-data")

    # assert body is at least bigger than fixture file
    expect($request.content_length > size).to be_truthy
  end

  it "GET /api/v1/gem_version.json" do
    result = @client.gem_version
    expect(result.succeeded).to be_truthy
    expect(result.response["major"]).to eq("0")
    expect(result.response["minor"]).to eq("2")
    expect(result.response["patch"]).to eq("1")
  end

  it "GET /api/v1/repos.json" do
    result = @client.repositories
    expect(result.succeeded).to be_truthy
    expect(result.response[0]["private"]).to be_truthy
    expect(result.response[0]["fqname"]).to eq("joedamato/test_repo")
    expect(result.response[0]["name"]).to eq("test_repo")
  end

  it "POST /api/v1/repos.json" do
    body = { "repository" => { "name" => "my_repo", "private" => "0" } }.to_json
    result = @client.create_repository("my_repo")
    expect(result.succeeded).to be_truthy
    expect($request.content_type).to include("json")
    expect($request.content_length).to eq(body.size)
  end

  it "GET /api/v1/repos/joedamato/test_repo.json" do
    result = @client.repository("test_repo")
    expect(result.succeeded).to be_truthy
    expect(result.response["private"]).to be_truthy
    expect(result.response["fqname"]).to eq("joedamato/test_repo")
    expect(result.response["name"]).to eq("test_repo")
  end

  it "GET /api/v1/repos/joedamato/invalid_repo.json (invalid repo)" do
    result = @client.repository("invalid_repo")
    expect(result.succeeded).to be_falsey
  end

  it "should have a distinct User-Agent that includes the version" do
    @client.distributions
    expect($request["User-Agent"]).to eq("packagecloud-ruby #{Packagecloud::VERSION}/test_client")
  end

  it "should raise if api has advanced too far" do
    current = Packagecloud::MINOR_VERSION
    Packagecloud::MINOR_VERSION = "1"
    credentials = Credentials.new("joedamato", "test_token")
    connection = Connection.new("http", "localhost", 8000)

    expect {
      Client.new(credentials, "test_client", connection)
    }.to raise_error(GemOutOfDateException)
    # Set this back to current
    Packagecloud::MINOR_VERSION = current
  end

  it "should suggest upgrading if patch version is higher" do
    current = Packagecloud::PATCH_VERSION
    Packagecloud::PATCH_VERSION = "0"
    credentials = Credentials.new("joedamato", "test_token")
    connection = Connection.new("http", "localhost", 8000)
    $stdout.should_receive(:write).with("[WARNING] There's a newer version of the packagecloud-ruby library. Update as soon as possible!")
    $stdout.should_receive(:write).with("\n")
    Client.new(credentials, "test_client", connection)
    # Set this back to current
    Packagecloud::PATCH_VERSION = current
  end

  it "invalid credentials should raise unauthenticated exception" do
    credentials = Credentials.new("joedamato", "test_tafdfasoken")
    connection = Connection.new("http", "localhost", 8000)
    expect {
      Client.new(credentials, "test_client", connection)
    }.to raise_error(UnauthenticatedException)
  end

  describe "find_distribution_id" do

    it "should find ubuntu/breezy" do
      id = @client.find_distribution_id("ubuntu/breezy")
      expect(id).to be(3)
    end

    it "should find just breezy" do
      id = @client.find_distribution_id("breezy")
      expect(id).to be(3)
    end

    it "should return nil for invalid distro" do
      id = @client.find_distribution_id("ubuasdalsdntu/breezy")
      expect(id).to be_nil
    end

    it "should raise for amiguous distro queries" do
      expect {
        @client.find_distribution_id("ubuntu")
      }.to raise_error
    end
  end


end
