class MongoUtils
  require 'mongo'
  require "uuidtools"

  def self.getClient()
    Mongo::Logger.logger.level = ::Logger::FATAL
    return Mongo::Client.new(ENV['MONGODB_URI'])
  end

  def self.createUser(name, email, password)
    user = {
      email: email,
      name: name,
      password: password
    }
    users.insert_one(user)
  end

  def self.findUser(email)
    client = self.getClient()
    users = client[:users]
    return users.find( { email: email } ).first
  end

  def self.updateTokens(email, tokens)
    client = self.getClient()
    users = client[:users]
    doc = users.find_one_and_update(
      { :email => email },
      { '$set' => {
        :access_token => tokens['access_token'],
        :refresh_token => tokens['refresh_token'] } }
    )
  end


  def self.getAccessToken(email)
    client = self.getClient()
    users = client[:users]
    user = users.find( { email: email } ).first
    return user[:access_token]
  end

  def self.createCategory(email, name, channels)
    client = self.getClient()
    categories = client[:categories]
    id = UUIDTools::UUID.timestamp_create.to_s()
    category = {
      id: id,
      name: name,
      user: email,
      channels: channels
    }
    categories.insert_one(category)
    self.addCategoryToUser(email, id)
  end

  def self.addCategoryToUser(email, category)
    client = self.getClient()
    users = client[:users]
    doc = users.find_one_and_update(
      { :email => email },
      { '$push' => {
        :categories => category } }
    )
  end



end
