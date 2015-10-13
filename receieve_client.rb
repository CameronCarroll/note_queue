#! /bin/ruby
# Note Queue Receieve Client: DELETES entries off of server and downloads them for addition to proper journal file.
# Author: Cameron Carroll, September 2015
# Required gems: curb

require 'curb'
require 'json'
require 'time'
require 'dir'

SERVER = "cammycorner.herokuapp.com/entries"
DOC_DIRECTORY = Dir.home + '/journal'

Dir.mkdir(DOC_DIRECTORY) unless Dir.exists?(DOC_DIRECTORY)

json = Curl.delete(SERVER)
data = JSON.parse(json.body_str)
data.each do |datum|
  date = Time.parse(datum['datestamp']).getlocal
  month = date.strftime('%B').downcase
  filename = DOC_DIRECTORY + month.to_s
  File.new(filename, 'w') unless File.exists?(filename)
  File.open(filename, 'a') do |file|
    date_banner = date.strftime("On %m/%d/%Y, at %I:%M%p:")
    file << date_banner << "\n"
    file << datum['message'] << "\n\n"
  end
end
