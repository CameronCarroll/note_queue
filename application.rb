require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/json'

require './model'

class CammyCorner < Sinatra::Application

  post '/entry' do
    stamp = Time.new
    message = params['message']
    result = Entry.create(:message => message , :datestamp => stamp)
    if result
      return 200
    else
      return 500
    end
  end

  delete '/entries' do
    entries = Entry.all
    Entry.all.destroy
    json entries
  end

  get '/' do
    erb :index
  end

  get '/register' do
    erb :create_account
  end

  post 'auth/login' do
  end

  post 'auth/create' do
  end
end
