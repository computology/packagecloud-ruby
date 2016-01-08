require 'spec_helper'
require 'packagecloud'

describe Package do
  it "should raise for nil file" do
    expect { Package.new }.to raise_error("file cannot be nil")
  end

  it "should raise for file that doesn't exist" do
    expect { Package.new(:file => "hi") }.to raise_error
  end

  it "should be able to open String file paths" do
    pkg = Package.new(:file => "spec/fixtures/chewbacca-1.0.0.gem")
    expect(pkg.filename).to eql("chewbacca-1.0.0.gem")
  end

  it "should be able to open File objects" do
    pkg = Package.new(:file => File.open("spec/fixtures/chewbacca-1.0.0.gem"))
    expect(pkg.filename).to eql("chewbacca-1.0.0.gem")
  end

  it "should raise if IO object is passed without filename" do
    fd = IO.sysopen("spec/fixtures/chewbacca-1.0.0.gem", "r")
    io = IO.new(fd)
    expect { Package.new(:file => io) }.to raise_error("filename cannot be nil")
  end

  it "should handle IO object if passed with filename" do
    fd = IO.sysopen("spec/fixtures/chewbacca-1.0.0.gem", "r")
    io = IO.new(fd)
    pkg = Package.new(:file => io, :filename => "chewbacca-1.0.0.gem")
    expect(pkg.filename).to eql("chewbacca-1.0.0.gem")
  end

  it "should handle source_files options" do
    pkg = Package.new(:file => "spec/fixtures/natty_dsc/jake_1.0-7.dsc", :source_files => {"foo" => "bar"})
    expect(pkg.source_files).to eql({"foo" => "bar"})
  end

  it "should always have a {} as default for source files" do
    pkg = Package.new(:file => "spec/fixtures/natty_dsc/jake_1.0-7.dsc", :source_files => nil)
    expect(pkg.source_files).to be_empty
  end

end
