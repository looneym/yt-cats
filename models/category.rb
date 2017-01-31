require 'mongoid'

require_relative './subscription.rb'
require_relative './user.rb'

class Category
  include Mongoid::Document

  field :name, type: String
  field :id, type: String
  field :channel_ids, type: Array, default: []

  embedded_in :user


end
