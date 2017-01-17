require 'mongoid'

require_relative './subscription.rb'

class User
  include Mongoid::Document
  field :name, type: String
  field :email, type: String
  field :access_token, type: String
  field :refresh_token, type: String

  embeds_many :categories

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
