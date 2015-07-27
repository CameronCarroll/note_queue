require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'

class CammyCorner < Sinatra::Application
  post '/entry' do
    # not shit
  end

  get '/entries' do
    'hi'
  end
end
