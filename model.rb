require 'data_mapper'
require 'dm-postgres-adapter'
require 'uuidtools'
require 'dm-serializer'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

class Entry
  include DataMapper::Resource

  property :id, Serial
  property :datestamp, DateTime
  property :message, Text
  property :uuid, UUID, :default => UUIDTools::UUID.random_create
end

def delete_all_entries
  Entry.all.destroy
end

DataMapper.finalize
DataMapper.auto_upgrade!
