require 'sinatra'
require 'yt'
require 'mongo'

require_relative './YTClient.rb'
require_relative './MongoUtils.rb'

enable :sessions

get '/' do
  authURL = YTClient.getAuthURL()
  erb :index, :locals => {:authURL => authURL}, :layout => :plain
end

get '/app/categories' do
  @testCats = ["News", "Technology", "Sport"]
  access_token = MongoUtils.getAccessToken('kurt@gmail.com')
  @subscriptions = YTClient.getSubscriptions(access_token)
  erb :categories
end

post '/app/categories' do
  email = "kurt@gmail.com"
  name = request.POST['category']
  request.POST.delete('category')
  channels = request.POST.values
  MongoUtils.createCategory(email, name, channels)
  redirect to('/app/categories')
end

get '/callback' do
  tokens = YTClient.getTokens(params[:code])
  MongoUtils.updateTokens('kurt@gmail.com', tokens)
  redirect to('/app/categories')
end

get '/subscriptions' do
  access_token = MongoUtils.getAccessToken('kurt@gmail.com')
  subscriptions = YTClient.getSubscriptions(access_token)
  erb :subscriptions, :locals => {:subscriptions => subscriptions}
end

get '/categories' do
  erb :categories
end
