class User
  attr_accessor :id, :oauth_id, :name, :access_token, :token_expiry

  def initialize(params)
    unless params['oauth_id'] && params['name']
      raise 'Cannot initialize user without both oauth id and name'
    end
  	self.id = params['id']
    self.oauth_id = params['oauth_id']
    self.access_token = params['access_token']
    self.token_expiry = params['token_expiry']
    self.name = params['name']
  end

  def ===(that)
  	if self.id == that.id &&
  		self.oauth_id == that.oauth_id &&
  		self.access_token == that.access_token &&
  		self.token_expiry == that.token_expiry &&
  		self.name == that.name
  		true
  	else
  		false
  	end
  end 
end