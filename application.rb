require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/json'
require 'pry'

require './model'

class CammyCorner < Sinatra::Application

  post '/entry' do
    Entry.create(:message => params['message'] , :datestamp => Time.new)
  end

  delete '/entries' do
    entries = Entry.all.to_json
    Entry.all.destroy
    json entries
  end
end
