require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/flash'
require 'warden'
require 'tilt/erb'
require 'pry'

require './model'

LOGIN_FAIL_MSG = "Login or Password was incorrect."

class NoteQueue < Sinatra::Application
  enable :sessions
  register Sinatra::Flash

  use Warden::Manager do |config|
    config.serialize_into_session{|user| user.id }
    config.serialize_from_session{|id| User.get(id)}
    config.scope_defaults :default,
    strategies: [:password],
    action: 'auth/unauthenticated'
    config.failure_app = NoteQueue
  end

  Warden::Manager.before_failure do |env,opts|
    env['REQUEST_METHOD'] = 'POST'
  end

  Warden::Strategies.add(:password) do
    def valid?
      params['login'] && params['password']
    end

    def authenticate!
      user = User.first(login: params['login'])
      if user.nil?
        fail!(LOGIN_FAIL_MSG)
      elsif user.authenticate(params['password'])
        success!(user)
      else
        fail(LOGIN_FAIL_MSG)
      end
    end
  end

  #############################################################################
  #############################################################################
  # Auth Routes:

  post '/auth/login' do
    env['warden'].authenticate!
    flash[:success] = env['warden'].message
    redirect '/dash'
  end

  get '/auth/logout' do
    # Apparently session won't clear without following inspection:
    env['warden'].raw_session.inspect
    env['warden'].logout
    flash[:success] = 'Logged out!'
    redirect '/'
  end

  post '/auth/unauthenticated' do
    status 401
    redirect '/'
  end

  post '/auth/create' do
    login = params[:login]
    password = params[:password]
    confirmation = params[:confirmation]

    if User.first(:login => login)
      # user exists already
      redirect '/register'
    else
      if password == confirmation
        user = User.create(:login => login, :password => password)
        binding.pry
        env['warden'].set_user(user)
        redirect '/dash'
      else
        # passwords didn't match
        redirect '/register'
      end
    end
  end
  #############################################################################
  #############################################################################
  # Program API Routes:

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

  #############################################################################
  #############################################################################
  # Website Routes:

  get '/' do
    bump_logged_in
    erb :index
  end

  get '/register' do
    erb :create_account
  end



  #############################################################################
  #############################################################################

  private

  def logged_in?
    env['warden'].user
  end

  def logged_out?
    !logged_in?
  end

  def bump_logged_in
    redirect '/dash' if logged_in?
  end

  def bump_logged_out
    redirect '/' if logged_out?
  end
end
