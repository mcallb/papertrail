#!/usr/bin/env ruby
require 'fileutils'
require 'open-uri'
require 'json'
require 'yaml'

unless ARGV.length == 1
  puts "Wrong number of arguments."
  puts "Usage: ruby get_logs.rb '/tmp/file/location' "
  exit
end

#Place to download the file
download_directory = ARGV[0]

#Load PaperTrail API key from config file
config = YAML.load_file('./.config.yaml')

#Create header for authentication
headers = {"X-Papertrail-Token" => config['PT_API_KEY']}
archive_endpoint = 'https://papertrailapp.com/api/v1/archives.json'

#Return the json
res = JSON.parse(open(archive_endpoint,headers).read)

#Sort by end date to get the latest file
res_sorted = res.sort_by { |end_date| end_date[:end] }

#Get the latest filename and url to download
filename = res_sorted[0]['filename']
href = res_sorted[0]['_links']['download']['href']

download_path = File.join(download_directory, filename)

#If the path doesn't exist create it
unless File.directory?(download_directory)
  puts "Directory not found creating it: #{download_directory}"
  FileUtils.mkdir_p download_directory
end

if File.file?(download_path)
  puts "The file #{download_path} already exists. Skipping file."
else
  open(download_path, 'wb') do |file|
    puts "Downloading file to: #{download_path}"
    open(href,headers) do |uri|
      file.write(uri.read)
      puts "Download complete!"
    end
  end
end

