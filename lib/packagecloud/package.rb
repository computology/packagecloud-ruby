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
      if distro_version_id
        @distro_version_id = distro_version_id
      end
      @source_files = source_files
    end

    def distro_version_id=(distro_version_id)
      deprec = "[DEPRECATION] distro_version_id on Package is deprecated, please pass distro_version_id to Client#put_package instead"
      warn deprec if distro_version_id
      @distro_version_id = distro_version_id
    end

  end
end
