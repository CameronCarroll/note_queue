require 'data_mapper'
require 'bcrypt'
require 'dm-postgres-adapter'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/ccdb')

class Entry
  include DataMapper::Resource
  include BCrypt

  property :id, Serial
  property :datestamp, DateTime
  property :message, BCryptHash
end
