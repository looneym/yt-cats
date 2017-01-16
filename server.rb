require 'sinatra'
require 'yt'
require 'mongo'
require 'mongoid'

require_relative './YTClient.rb'
require_relative './MongoUtils.rb'
require_relative './user.rb'
# require_relative './hobby.rb'

enable :sessions

configure do
  Mongoid.load!("./mongoid.yml", :production)
end

get '/' do
  erb :index
end

get '/auth' do
  authURL = YTClient.getAuthURL()
  erb :auth, :locals => {:authURL => authURL}, :layout => :plain
end

get '/callback' do
  tokens = YTClient.getTokens(params[:code])
  session[:tokens] = tokens
  redirect to('/setup')
end

get '/setup' do
  @account = YTClient.getAccount(session[:tokens]["access_token"])
  session[:email] = @account.email
  puts session["email"]
  MongoUtils.burnItAll()
  MongoUtils.createUser(session[:email], "password", session[:tokens])
  erb :setup
end

get '/app/categories' do
  access_token = MongoUtils.getAccessToken(session[:email])
  @subscriptions = YTClient.getSubscriptions(access_token)
  @categories = MongoUtils.getCategories(session[:email])
  erb :categories
end

post '/app/categories' do
  name = request.POST['category']
  request.POST.delete('category')
  channels = request.POST.values
  MongoUtils.createCategory(session[:email], name, channels)
  redirect to('/app/categories')
end

get '/app/categories/view' do
  @id = params[:id]
  @categories = MongoUtils.getCategories(session[:email])
  @current_category = MongoUtils.getCategory(@id)
  channels = @current_category['channels']
  @category_videos = Array.new
  channels.each do |c|
    videos = YTClient.getChannelVideos(c)
    videos.each do |v|
      @category_videos.push(v)
    end
  end
  @category_videos.sort! { |a,b| b.snippet.published_at <=> a.snippet.published_at }
  erb :view_category
end

post '/app/subscriptions' do
  MongoUtils.syncSubscriptions("kurt@gmail.com")
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

get '/app/test' do
  erb :test
end

get '/user' do
  user = User.new(name: "Joey Jo Jo")
  user.save!
  @user1 = User.where(name: "Joey Jo Jo").first
  erb :user, :layout => :plain
end
