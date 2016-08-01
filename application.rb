require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/flash'
require 'warden'
require 'tilt/erb'
require 'securerandom'
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
        api_key = SecureRandom.urlsafe_base64
        api_secret = SecureRandom.urlsafe_base64
        user = User.create(:login => login, :password => password, :api_key => api_key, :api_secret => api_secret)
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
    error = authenticate_errors
    return error if error
    stamp = Time.new
    # Message comes through with spaces on either side, remove them:
    return 400 unless params['text']
    message = params['text'].sub(/^\s/, '').sub(/\s$/, '')
    # We need user ID:
    user_id = env['warden'].user.id
    # I was having a lot of trouble here, where it just refused to create the record, but it seems I forgot to hook up the user_id, and because it belongs to a user it was failing.
    result = Entry.create(:message => message , :datestamp => stamp, :user_id => user_id)
    if result.id
      return 201
    else
      return 500
    end
  end

  delete '/entries' do
    error = authenticate_errors
    return error if error
    user = env['warden'].user
    entries = Entry.all(:user_id => user.id)
    json_string = json(entries)
    entries.destroy
    json_string
  end

  #############################################################################
  #############################################################################
  # Website Routes:

  get '/' do
    bump_logged_in
    erb :index
  end

  get '/register' do
    bump_logged_in
    erb :create_account
  end

  get '/dash' do
    bump_logged_out
    user = env['warden'].user
    @api_key = user.api_key
    @api_secret = user.api_secret
    erb :dash
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

  # Returns nil on success
  # Returns appropriate error code otherwise
  def authenticate_errors
    # Get HTTP_AUTHORIZATION header
    # This is set up by the client's request
    header = env["HTTP_AUTHORIZATION"]
    if header
      # Header in format "Authorization: {key}:{secret}"
      header = header.split(':')
      # Not sure if I should have done this in client instead, clearing out extra spaces from API Key
      header[1].sub!(' ', '')
      key = header[1]
      hmac_message = header[2]
      user = User.first(api_key: key)
      return 401 unless user
      secret = user.api_secret
      uri = env['REQUEST_URI']
      # Text could either be sent to us from client, or could be nil in the case of a retrieval request:
      text = params['text'] ? params['text'] : ''
      # Now with all our parameters gathered, we can calculated HMAC and compare to what client sent us
      computed_hmac = OpenSSL::HMAC.hexdigest('SHA256', secret, text + uri)
      if hmac_message == computed_hmac
        env['warden'].set_user(user)
        return nil # Success!
      else
        return 401 # Failed to Authenticate
      end
    else
      return 401 # Failed to Authenticate
    end
  end
end
