#! /bin/ruby
# Note Queue Send Client: Ruby program to send messages to NoteQueue, a simple server intended to multiplex journal entries from various devices into a single destination.
# Author: Cameron Carroll, September 2015
# Required Gems: curb

SERVER = "cammycorner.herokuapp.com/entry"

require 'curb'

if ARGV.length > 0
  input = ' '
  ARGV.each do |arg|
    input += arg + ' '
  end
else
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

http = Curl.post(SERVER, {:message => input})
puts http.status
