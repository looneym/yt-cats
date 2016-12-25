# require 'mongo'
require 'mongo_mapper'

# Mongo::Logger.logger.level = ::Logger::FATAL
#
# client = Mongo::Client.new('mongodb://root:root@ds145168.mlab.com:45168/yt-cats')
#
# db = client.database
#
# db.collections.each {|i| puts i.name }
#
# collection = client[:users]
#
# doc = { name: 'Steve', hobbies: [ 'hiking', 'tennis', 'fly fishing' ] }
#
# result = collection.insert_one(doc)


MongoMapper.setup({'production' => {'uri' => ENV['MONGODB_URI']}}, 'production')



class User
  include MongoMapper::Document

  key :email, String

  many :subscriptions
end


class Subscription
  include MongoMapper::EmbeddedDocument

  key :name,    String

end

user = User.new(:name => "Kurt Vonnegut")

found_user = User.find_by_name("Kurt Vonnegut")

puts user
