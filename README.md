## packagecloud-ruby

Ruby library for communicating with the [packagecloud.io](https://packagecloud.io) API.

* [Homepage](https://rubygems.org/gems/packagecloud-ruby)
* [Documentation](http://rubydoc.info/gems/packagecloud-ruby/frames)
* [Email](mailto:support@packagecloud.io)


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

Login to [packagecloud.io](https://packagecloud.io) and visit
the [API docs](https://packagecloud.io/docs/api#api_tokens) to see your token.

## Creating a Client

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

  ```ruby
  # Get all distributions
  distros = @client.distributions

  # Looking up a distribution id by name
  id = @client.find_distribution_id("centos/6") # returns 12
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

### Packages

  ```ruby
  # Create Packages (takes IO object for file)
  rpm_package = Package.new(open("libcurl-0.1.2.rpm"), 12) # 12 being the distribution id for centos/6, for example
  gem_package = Package.new(open("rails-4.0.0.gem"))       # distribution id's not required for gems

  # Creating source Packages
  source_files = { "jake_1.0.orig.tar.bz2" => open("/path/jake_1.0.orig.tar.bz2"),
                   "jake_1.0-7.debian.tar.gz" => open("/path/jake_1.0-7.debian.tar.gz") }
  dsc_package = Package.new("jake_1.0-7.dsc", 20, source_files)

  # Upload Packages
  @client.put_package("test_repo", gem_package)
  @client.put_package("test_repo", rpm_package)
  @client.put_package("test_repo", dsc_package)
  ```

## Copyright

Copyright (c) 2014 Computology, LLC

See LICENSE.txt for details.
