require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
require './model.rb'
require 'json'

require 'pry' # ############### <-- ########## <--- ########## <-- it's pry!
class CammyCorner < Sinatra::Application
  post '/entry' do
    message = params[:message]
    Entry.create(:datestamp => Time.new, :message => message)
  end

  get '/entries' do
    content_type :json
    Entry.all.to_json
    Entry.all.delete
  end
end
