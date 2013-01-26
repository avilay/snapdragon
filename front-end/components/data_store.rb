require 'pg'
require 'uri'
require 'bookmark'
require 'user'
require 'helpers'
require 'sql_queries'

class DataStore
  include SqlQueries

  attr_reader :user_id

  def initialize(params)    
    raise 'Cannot create datastore without dbname' unless dbname = params[:dbname]
    @user_id = params[:user_id]
    @logger = params[:logger]
    @conn = PG.connect(dbname: dbname)
  end

  def add_or_get_user(proto)
    @user_id = nil
    users = @conn.exec(GET_USR, [proto.oauth_id, proto.name])
    if users.count == 0
      dup = @conn.exec(CHK_USR, [proto.oauth_id])
      raise "User with oauth id #{proto.oauth_id} already exists" unless dup.count == 0
      @conn.exec(INS_USR, [proto.oauth_id, proto.access_token, proto.token_expiry, proto.name, Time.new, Time.new])
      users = @conn.exec(GET_USR, [proto.oauth_id, proto.name]) 
    end
    user = User.new(users.first)    
    @user_id = user.id
    user
  end
  
  def add_or_get_link(url)
    lns = @conn.exec(CHK_LN, [url])
    if lns.count == 1
      link_id = lns.first["id"]
    else
      link_id = @conn.exec(INS_LN, [url, SdHelpers.title(url)]).first['id']
    end
    @conn.exec(GET_LN, [link_id]).first
  end
end