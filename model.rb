require 'data_mapper'
require 'dm-postgres-adapter'
require 'dm-serializer'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/camdev')

class Entry
  include DataMapper::Resource

  property :id, Serial
  property :datestamp, DateTime
  property :message, Text
end

DataMapper.finalize
DataMapper.auto_upgrade!
