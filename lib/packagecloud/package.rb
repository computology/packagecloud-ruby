module Packagecloud
  class Package

    attr_reader :file
    attr_reader :distro_version_id
    attr_accessor :source_files
    attr_reader :filename

    def initialize(file,
                   distro_version_id=nil,
                   source_files={},
                   filename=rand(2**32).to_s(36))

      raise ArgumentError, 'file cannot be nil' if file.nil?
      @file = file
      @filename = filename
      @distro_version_id = distro_version_id
      @source_files = source_files
    end

  end
end