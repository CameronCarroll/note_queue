#! /bin/ruby
# Note Queue Send Client: Ruby program to send messages to NoteQueue, a simple server intended to multiplex journal entries from various devices into a single destination.
# Author: Cameron Carroll, September 2015
# Required Gems: curb
# Required programs:

# On application server we ask rack for the URI
# and it includes http:// before
# So we have to make sure it's the same or HMAC auth fails

#SERVER = "http://localhost:9393/entry"
SERVER = "http://cammycorner.herokuapp.com/entry"

require 'curb'
require 'openssl'
require_relative 'keylib'
require 'pry'

# Reads in keys stored locally, or asks user to copy/paste them off of website.
keys = NQKeylib.keys
key = keys[0]
secret = keys[1]

# Either accept input text directly as program argument,
if ARGV.length > 0
  input = ' '
  ARGV.each do |arg|
    input += arg + ' '
  end
else
  # or pass no argument and fire up VIM instead
  TEMPFILE = 'daylog.tmp'
  system("vim #{TEMPFILE}")
  input = ""
  begin
    File.open(TEMPFILE, 'r') do |tempfile|
      while (line = tempfile.gets)
        input << line
      end
    end
  rescue => err
    puts err
    err
  end
  File.delete TEMPFILE
end

# Now to construct the HMAC authentication.
# The message to sign is our request body plus request path.
message = input + SERVER
signature = OpenSSL::HMAC.hexdigest('SHA256', secret, message)
# Most authorization headers I've seen have some kind of identifier before
# the key/pair, but the scheme for Sinatra I was following ommitted it.
# Amazon stuck AWS in theirs, so I could conceivably put whatever.
header = "Authorization: #{key}:#{signature}"
http = Curl.post(SERVER, {:text => input}) do |http|
  http.headers['Authorization'] = header
end


puts http.status
