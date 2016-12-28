require 'sinatra'
require 'yt'
require 'mongo'

require_relative './YTClient.rb'
require_relative './MongoUtils.rb'

enable :sessions

get '/' do
  authURL = YTClient.getAuthURL()
  erb :index, :locals => {:authURL => authURL}
end

get '/callback' do
  tokens = YTClient.getTokens(params[:code])
  MongoUtils.updateTokens('kurt@gmail.com', tokens)
  redirect to('/subscriptions')
end

get '/subscriptions' do
  access_token = MongoUtils.getAccessToken('kurt@gmail.com')
  subscriptions = YTClient.getSubscriptions(access_token)
  erb :subscriptions, :locals => {:subscriptions => subscriptions}
end

get '/categories' do
  erb :categories
end
