require 'mongoid'
require 'securerandom'

require_relative './subscription.rb'

class User
  include Mongoid::Document

  field :name, type: String
  field :email, type: String
  field :access_token, type: String
  field :refresh_token, type: String

  embeds_many :subscriptions
  embeds_many :categories

  def syncSubscriptions(subscriptions)
    subscriptions.each do |s|
      self.subscriptions.new(
        channel_id: s.id,
        image_url: s.snippet.thumbnails['default']['url'],
        title: s.snippet.title,
        description: s.snippet.description)
    end
  end

  def createCategory(name, subscriptions)
    self.categories.new(
      name: name,
      id: SecureRandom.hex(4),
      channel_ids: subscriptions
    )
  end

  def updateTokens(tokens)
    self.update_attributes!(
      access_token: tokens["access_token"],
      refresh_token: tokens["refresh_token"]
    )
  end  

end
