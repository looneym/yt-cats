require 'mongoid'

require_relative './subscription.rb'

class User
  include Mongoid::Document
  field :name, type: String
  field :email, type: String
  field :access_token, type: String
  field :refresh_token, type: String

  embeds_many :subscriptions


  def self.exists(db, email)
    user = db[:users].find( {email: email} ).limit(1)
    # true if user exists
    return  user.first != nil
  end

  def syncSubscriptions(subscriptions)
    subscriptions.each do |s|
      self.subscriptions.new(
        id: s.id,
        image_url: s.snippet.thumbnails['default']['url'],
        title: s.snippet.title,
        description: s.snippet.description)
    end
  end

end
