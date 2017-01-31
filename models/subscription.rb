require 'mongoid'
require_relative './user.rb'

class Subscription
  include Mongoid::Document

  field :channel_id, type: String
  field :image_url, type: String
  field :title, type: String
  field :description, type: String

  embedded_in :user

end
