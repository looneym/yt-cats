class MongoUtils
  require 'mongo'

  def self.getClient()
    Mongo::Logger.logger.level = ::Logger::FATAL
    return Mongo::Client.new(ENV['MONGODB_URI'])
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



end
