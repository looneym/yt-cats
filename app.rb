require_relative './helpers/YTClient.rb'
require_relative './models/user.rb'
require_relative './models/category.rb'

require 'sinatra'
require 'mongoid'
require 'json'

enable :sessions

configure do
  Mongoid.load!("./mongoid.yml", :production)
end

# landing page
get '/' do
  erb :index
end

# entry point to the OAuth flow
get '/auth' do
  authURL = YTClient.getAuthURL()

  erb :auth, :locals => {:authURL => authURL}, :layout => :plain
end

# authenticated users enter the application here
get '/callback' do
  # exchange the code for tokens so that we can start to query the API
  tokens = YTClient.getTokens(params[:code])
  # retrieve the user's email from the API and determine if they are new
  @account = YTClient.getAccount(tokens["access_token"])
  subscriptions = YTClient.getSubscriptions(tokens["access_token"])

  session[:email] = @account.email

  if User.where(email: session[:email]).exists?
    @current_user = User.where(email: session[:email]).first
    @current_user.updateTokens(tokens)
    @current_user.syncSubscriptions(subscriptions)
    @current_user.save!
  else
    @current_user = User.new(
      email: session["email"],
      access_token: session[:tokens]["access_token"],
      refresh_token: session[:tokens]["refresh_token"] )
    @current_user.syncSubscriptions(subscriptions)
    @current_user.save!
  end

  redirect to('/app/categories')
end


# update categories
get '/app/categories' do
  @current_user = User.where(email: session[:email]).first

  erb :categories
end

# update categories (handle form)
post '/app/categories' do
  @current_user = User.where(email: session[:email]).first
  name = request.POST['category']
  request.POST.delete('category')
  # channel_ids for category
  subscriptions = request.POST.values

  @current_user.createCategory(name, subscriptions)
  @current_user.save!

  redirect to('/app/categories')
end

get '/app/categories/view' do
  @current_user = User.where(email: session[:email]).first
  @id = params[:id]
  @current_category = @current_user.categories.where(id: @id).first
  channels = @current_category.channel_ids

  @category_videos = Array.new
  channels.each do |c|
    videos = YTClient.getChannelVideos(c)
    videos.each do |v|
      @category_videos.push(v)
    end
  end
  @category_videos.sort! { |a,b| b.snippet.published_at <=> a.snippet.published_at }



 @category_video_ids = Array.new
 @category_videos.each do |v|
   @category_video_ids.push(v.id)
 end
 @category_video_ids = @category_video_ids.to_json


  erb :view_category
end

get '/player' do
  erb :player
end
