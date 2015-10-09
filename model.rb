require 'data_mapper'
require 'dm-postgres-adapter'
require 'dm-serializer'
require 'bcrypt'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/camdev')

class Entry
  include DataMapper::Resource

  property :id, Serial
  property :datestamp, DateTime
  property :message, Text, :lazy => false

  belongs_to :user
end

class User
  include DataMapper::Resource
  include BCrypt

  property :id, Serial
  property :login, String, :length => 3..50
  property :password, BCryptHash

  has n, :entries

  def authenticate(attempted_password)
    self.password == attempted_password
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!
