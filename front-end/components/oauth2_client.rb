require 'json'
require 'open-uri'

class OAuth2Client
  attr_reader :app_id, :app_secret, :auth_done, :state, :auth_grant
  attr_reader :login_url, :token_url, :user_url
  attr_accessor :logger

  def initialize(settings)
    @app_id = settings.app_id
    @app_secret = settings.app_secret
    @auth_done = settings.auth_done
    @state = settings.state
    @login_url = "https://www.facebook.com/dialog/oauth?client_id=#{@app_id}&redirect_uri=#{@auth_done}&state=#{@state}"
    @token_url = "https://graph.facebook.com/oauth/access_token?client_id=#{@app_id}&redirect_uri=#{@auth_done}&client_secret=#{@app_secret}&code="
    @user_url = "https://graph.facebook.com/me?access_token="
  end

  def authenticate(params)
    raise 'We seem to be a victim of CSRF' unless params[:state] == @state
    if @auth_grant = params[:code]
      token = get_access_token
      get_user_details(token)
    elsif params[:error]
      logger.warn("User denied permisssion")
      false
    end
  end  

  def get_access_token
    @token_url +=@auth_grant
    response = URI.parse(URI.encode(@token_url)).read      
    token = {}
    response.split('&').each do |p|
      flds = p.split('=')
      token[flds[0].chomp] = flds[1].chomp
    end
    token    
  end

  def get_user_details(token)
    @user_url += token['access_token']
    response = URI.parse(URI.encode(@user_url)).read
    user = JSON.parse(response)
    user['access_token'] = token['access_token']
    user['token_expiry'] = Time.now + Integer(token['expires'])
    user['oauth_id'] = user['id']
    user.delete('id')
    user 
  end
end