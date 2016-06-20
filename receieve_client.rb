#! /bin/ruby
# Note Queue Receieve Client: DELETES entries off of server and downloads them for addition to proper journal file.
# Author: Cameron Carroll, September 2015
# Required gems: curb

require 'curb'
require 'json'
require 'time'
require 'openssl'
require_relative 'keylib'

require 'pry'

# On application server we ask rack for the URI
# and it includes http:// before
# So we have to make sure it's the same or HMAC auth fails

#SERVER = "http://localhost:9393/entries"
SERVER = "http://cammycorner.herokuapp.com/entries"
DOC_DIRECTORY = Dir.home + '/journal/'

Dir.mkdir(DOC_DIRECTORY) unless Dir.exists?(DOC_DIRECTORY)

# HMAC AUTHENTICATION: -------------------------------
# See send_cient.rb for detailed comments on this section
keys = NQKeylib.keys
key = keys[0]
secret = keys[1]


# Using a DELETE request because we want to wipe out all data on the server and instead use receieve_client to aggregate data to its final destination.
message = SERVER
signature = OpenSSL::HMAC.hexdigest('SHA256', secret, message)
header = "Authorization: #{key}:#{signature}"
json = Curl.delete(SERVER) do |http|
  http.headers['Authorization'] = header
end

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
