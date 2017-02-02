class YTClient
  require 'unirest'
  require 'CGI'
  require 'yt'


  def self.getClient
    Yt.configure do |config|
      config.client_id = ENV['YT_CLIENT_ID']
      config.client_secret = ENV['YT_CLIENT_SECRET']
      config.log_level = :debug
    end
  end

  def self.getAccount(access_token)
    return Yt::Account.new access_token: access_token
  end

  def self.getAuthURL
    encodedCallbackURL = CGI.escape("http://localhost:4567/callback")
    authURL =  'https://accounts.google.com/o/oauth2/auth' \
           '?client_id=' + ENV['YT_CLIENT_ID'] + \
           '&redirect_uri=' + encodedCallbackURL +
           '&scope=https://www.googleapis.com/auth/youtube%20https://www.googleapis.com/auth/userinfo.email'\
           '&response_type=code'\
           '&access_type=offline'\
           '&approval_prompt=force'
    return authURL
  end

  def self.getSubscriptions(access_token)
    account = Yt::Account.new access_token: access_token
    return account.subscribed_channels
  end

  def self.getTokens(code)
    response = Unirest.post "https://accounts.google.com/o/oauth2/token",
                        parameters:{
                          :code => code,
                          :client_id => ENV['YT_CLIENT_ID'],
                          :client_secret => ENV['YT_CLIENT_SECRET'],
                          :redirect_uri => 'http://localhost:4567/callback',
                          :grant_type => 'authorization_code'
                        }
    return response.body
  end

  def self.getChannelVideos(id)
    Yt.configuration.api_key = "AIzaSyCUDS_fklJJz1h5CbNEIwkKk-fACM4v6ac"
    channel = Yt::Channel.new id: id
    return channel.videos.take(5)
  end

  def self.getChannel(id)
    Yt.configuration.api_key = "AIzaSyCUDS_fklJJz1h5CbNEIwkKk-fACM4v6ac"
    channel = Yt::Channel.new id: id
    return channel
  end

  def self.getVideo(id)
    Yt.configuration.api_key = "AIzaSyCUDS_fklJJz1h5CbNEIwkKk-fACM4v6ac"
    video = Yt::Video.new id: id
    return video.snippet
  end


end
