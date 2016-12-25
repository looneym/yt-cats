require 'sinatra'
require 'yt'
require_relative './YTClient.rb'

enable :sessions

get '/' do
  authURL = YTClient.getAuthURL()
  erb :index, :locals => {:authURL => authURL}
end

post '/users' do
  payload = JSON.parse(request.body.read)
  if payload["type"] == "user.created"
    Users.create(payload)
  elsif payload["type"] == "user.updated"
    Users.update(payload)
  end
end

get '/callback' do
  session[:code] = params[:code]
  redirect to('/subscriptions')
end

get '/subscriptions' do
  code = session[:code]
  subscriptions = YTClient.getSubscriptions(code)
  erb :subscriptions, :locals => {:subscriptions => subscriptions}
end
