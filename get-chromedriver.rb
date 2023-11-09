#!/usr/bin/env ruby

require "fileutils"
require "json"
require "net/http"
require "tmpdir"

# Service to download ChromeDriver based on current Chrome version
class ChromeDriverDownloader
  def self.download
    new.download
  end

  def download
    return if File.exist?("~/bin/chromedriver-#{major_version}")

    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        FileUtils.mkdir_p "#{ENV["HOME"]}/bin" unless File.exist?("#{ENV["HOME"]}/bin")
        fetch
        unzip
        install
        symlink
      end
    end
  end

  private

  def fetch
    `curl #{latest_platform_url} > chromedriver.zip`
  end

  def unzip
    `unzip chromedriver.zip`
  end

  def install
    FileUtils.mv("./chromedriver-#{platform}/chromedriver", install_path)
  end

  def symlink
    File.unlink(symlink_path) if File.exist?(symlink_path)
    File.symlink(install_path.to_s, symlink_path)
  end

  def symlink_path
    "#{ENV["HOME"]}/bin/chromedriver"
  end

  def chrome_version
    @chrome_version ||= (`'/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome' --version`).gsub(/[^0-9\.]/, "")
  end

  def platform
    "mac-arm64"
  end

  def major_version
    @major_version || chrome_version.split(".").first
  end

  def latest_platform_url
    response = Net::HTTP.get(URI(download_json_api_url))
    parsed_response = JSON.parse(response)
    urls = parsed_response.dig("milestones", "#{major_version}", "downloads", "chromedriver")
    urls.find { |url| url["platform"] == platform }["url"]
  end

  def download_json_api_url
    "https://googlechromelabs.github.io/chrome-for-testing/latest-versions-per-milestone-with-downloads.json"
  end

  def install_path
    "#{ENV["HOME"]}/bin/chromedriver-#{major_version}"
  end
end

ChromeDriverDownloader.download if $PROGRAM_NAME == __FILE__
