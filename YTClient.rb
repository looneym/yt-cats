class YTClient
  require 'unirest'
  require 'CGI'


  def self.getClient
    Yt.configure do |config|
      config.client_id = ENV['YT_CLIENT_ID']
      config.client_secret = ENV['YT_CLIENT_SECRET']
      config.log_level = :debug
    end
  end

  def self.getAuthURL
    encodedCallbackURL = CGI.escape("http://localhost:4567/callback")
    authURL =  'https://accounts.google.com/o/oauth2/auth' \
           '?client_id=' + ENV['YT_CLIENT_ID'] + \
           '&redirect_uri=' + encodedCallbackURL +
           '&scope=https://www.googleapis.com/auth/youtube'\
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

end
