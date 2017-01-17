require_relative './YTClient.rb'
require_relative './MongoUtils.rb'
require_relative './user.rb'

require 'sinatra'
require 'sinatra/base'
require 'yt'
require 'mongo'
require 'mongoid'



class App < Sinatra::Base

  enable :sessions

  configure do
    Mongoid.load!("./mongoid.yml", :production)
    set :db, Mongo::Client.new(ENV['MONGODB_URI'])
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

    session[:tokens] = tokens
    session[:email] = @account.email

    if User.exists(settings.db, @account.email)
      redirect to('/app/categories')
    else
      redirect to('/setup')
    end

  end

  # first time setup for new users
  get '/setup' do
    @user = User.new(
      email: session["email"],
      access_token: session[:tokens]["access_token"],
      refresh_token: session[:tokens]["refresh_token"] )

    subscriptions = YTClient.getSubscriptions(session[:tokens]["access_token"])
    @user.syncSubscriptions(subscriptions)
    @user.save!
    erb :setup
  end

  # update categories
  get '/app/categories' do
    # access_token = MongoUtils.getAccessToken(session[:email])
    @current_user = User.where(email: session[:email]).first
    @categories = MongoUtils.getCategories(session[:email])
    erb :categories
  end

  # update categories (handle form)
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

  run! if app_file == $0

end
