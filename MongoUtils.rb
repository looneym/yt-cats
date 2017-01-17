class MongoUtils
  require 'mongo'
  require "uuidtools"

  require_relative './YTClient.rb'

  def self.getClient()
    Mongo::Logger.logger.level = ::Logger::FATAL
    return Mongo::Client.new(ENV['MONGODB_URI'])
  end

  def self.createUser(email, password, tokens)
    client = self.getClient()
    users = client[:users]
    user = {
      email: email,
      password: password,
      access_token: tokens['access_token'],
      refresh_token: tokens['refresh_token']
    }
    users.insert_one(user)
  end

  def self.burnItAll()
    client = self.getClient()
    users = client[:users]
    result = users.delete_many({})
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

  def self.syncSubscriptions(email)
    client = self.getClient()
    users = client[:users]

    access_token = self.getAccessToken(email)
    subscriptions = YTClient.getSubscriptions(access_token)

    puts subscriptions.to_json

    users.find_one_and_update(
      { :email => email },
      { '$set' => {
        :subscriptions => subscriptions.to_json } }
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
    # self.addCategoryToUser(email, id)
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

  def self.getCategories(email)
    client = self.getClient()
    categories = client[:categories]
    user_categories = categories.find( { user: email } )
    return user_categories
  end

  def self.getCategory(id)
    client = self.getClient()
    categories = client[:categories]
    return categories.find( { id: id } ).first

  end



end
