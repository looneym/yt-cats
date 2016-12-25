class YTClient

  def self.getClient
    Yt.configure do |config|
      config.client_id = ENV['YT_CLIENT_ID']
      config.client_secret = ENV['YT_CLIENT_SECRET']
      config.log_level = :debug
    end
  end

  def self.getAuthURL
    self.getClient()
    scopes = ['youtube', 'userinfo.email']
    redirect_uri = 'http://localhost:4567/callback'
    return Yt::Account.new(scopes: scopes, redirect_uri: redirect_uri).authentication_url
  end

  def self.getSubscriptions(code)
    redirect_uri = 'http://localhost:4567/callback'
    account = Yt::Account.new authorization_code: code, redirect_uri: redirect_uri
    return account.subscribed_channels
  end

end
