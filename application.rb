require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/json'
require 'pry'

require './model'

class CammyCorner < Sinatra::Application

  post '/entry' do
    stamp = Time.new
    message = params['message']
    Entry.create(:message => message , :datestamp => stamp)
    puts "Created entry: #{message} at #{stamp}"
  end

  delete '/entries' do
    entries = Entry.all
    puts "Deleting entries: #{entries.inspect}"
    Entry.all.destroy
    json entries
  end
end
