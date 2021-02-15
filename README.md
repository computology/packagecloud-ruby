## packagecloud-ruby

![Build Status](https://travis-ci.org/computology/packagecloud-ruby.svg?branch=master "Build Status")
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fcomputology%2Fpackagecloud-ruby.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2Fcomputology%2Fpackagecloud-ruby?ref=badge_shield)


Ruby library for communicating with the [packagecloud.io](https://packagecloud.io) API.

* [Homepage](https://rubygems.org/gems/packagecloud-ruby)
* [Documentation](http://rubydoc.info/gems/packagecloud-ruby/frames)
* [Email](mailto:support@packagecloud.io)

## Goals

This library aims to have widest amount of compatibility possible between Ruby versions and implementations. All dependencies are pure Ruby and kept to a minimum to ensure this.

#### Tested Rubies
  
  * Ruby 1.8.x, 1.9x, and 2.x

## Implemented API Endpoints

  * [Get Package Contents](https://packagecloud.io/docs/api#resource_packages_method_contents)
  * [Upload Package](https://packagecloud.io/docs/api#resource_packages_method_create)
  * [List Distributions](https://packagecloud.io/docs/api#resource_distributions_method_index)
  * [View Repository](https://packagecloud.io/docs/api#resource_repositories_method_show)
  * [View Repositories](https://packagecloud.io/docs/api#resource_repositories_method_index)
  * [Create Repository](https://packagecloud.io/docs/api#resource_repositories_method_create)

## Installation

  ```
  gem install packagecloud-ruby
  ```

## Getting your API token

Login to [packagecloud.io](https://packagecloud.io) and
go to your [Account Settings](https://packagecloud.io/api_token) to see your API token.

## Creating a Client

  Note that you should not use the email address associated with your
  [packagecloud.io](https://packagecloud.io) account when accessing the API.
  Please use your username on the site.

  ```ruby
  require 'packagecloud'

  # Create a client using your username and API token
  credentials = Packagecloud::Credentials.new("joedamato", "my_api_token")
  @client = Packagecloud::Client.new(credentials)

  ```

## Result objects

  Every client API method call returns a ```Result``` object, which is simply:

  ```ruby
  module Packagecloud
    class Result
      attr_accessor :response
      attr_accessor :succeeded
    end
  end
  ```

  If ```.succeeded``` is ```true``` then, ```.response``` is the parsed JSON response
  of that endpoint, otherwise ```.response``` is the error text explaining what went wrong.


## Usage

### Distributions

  This is the list of currently [supported distributions](https://packagecloud.io/docs#os_distro_version).

  ```ruby
  # Get all distributions
  distros = @client.distributions

  # Looking up a distribution id by name
  id = @client.find_distribution_id("el/6") # returns 27
  ```

### Repositories

  ```ruby
  # Looking up all repositories available for a client
  repos = @client.repositories

  # Lookup info on a single repo
  repo = @client.repository("my_repo")

  # Creating a repository
  @client.create_repository("my_repo")

  ```

  When specifying your repository name, you should use just the name and not
  the fully qualified name (fqname).

  For example:

  ```ruby
  # INCORRECT: this should just be "my_repo"
  repo = @client.repository("user/my_repo")
  ```

### Packages

  ```ruby
  # Create RPM Packages (can take File, IO, or path argument)
  rpm_package = Packagecloud::Package.new(:file => "libcurl-0.1.2.rpm")

  # Creating gem Packages using IO (needs :filename passed in)
  gem_package = Packagecloud::Package.new(:file => io_object, :filename => "rails-4.0.0.gem")

  # Creating source Packages
  source_files = { "jake_1.0.orig.tar.bz2" => open("/path/jake_1.0.orig.tar.bz2"),
                   "jake_1.0-7.debian.tar.gz" => open("/path/jake_1.0-7.debian.tar.gz") }
  dsc_package = Packagecloud::Package.new(:file => "jake_1.0-7.dsc", :source_files => source_files)

  # Upload Packages
  @client.put_package("test_repo", gem_package)
  @client.put_package("test_repo", rpm_package, "el/6")
  @client.put_package("test_repo", dsc_package, "ubuntu/trusty")
  @client.put_package("test_repo", node_package, "node")
  ```

## Copyright

Copyright (c) 2014-2018 Computology, LLC

See LICENSE.txt for details.


## License
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fcomputology%2Fpackagecloud-ruby.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2Fcomputology%2Fpackagecloud-ruby?ref=badge_large)