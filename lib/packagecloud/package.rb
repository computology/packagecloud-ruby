module Packagecloud
  class Package

    attr_reader :file
    attr_reader :distro_version_id
    attr_accessor :source_files
    attr_reader :filename
    attr_reader :client

    def initialize(options = {})
      if options[:file].nil?
        raise ArgumentError, 'file cannot be nil' if file.nil?
      end
      if options[:file].is_a? String
        options[:file] = File.open(options[:file])
      end
      if options[:file].is_a? File
        options[:filename] = File.basename(options[:file].path)
      end
      if options[:filename].nil?
        raise ArgumentError, 'filename cannot be nil' if file.nil?
      end

      @file = options[:file]
      @filename = options[:filename]
      @distro_version_id = options[:distro_version_id]
      @source_files = options[:source_files] || {}
      @client = options[:client]
    end

  end
end
