require 'pg'
require 'uri'
require 'bookmark'
require 'user'
require 'helpers'
require 'sql_queries'

class DataStore
  include SqlQueries

  attr_reader :user_id

  def initialize(conn_str) 
    raise 'Cannot initialize DataStore with an empty connection string' unless conn_str    
    params = parse_conn_str(conn_str)
    @conn = PG.connect(params)
  end

  def parse_conn_str(conn_str)
    matches = %r{(.*?)://(.*):(.*)@(.*)/(.*)}.match(conn_str)
    params = {}
    #params[:dbtype] = matches[1]
    params[:user] = matches[2].strip
    params[:password] = matches[3].strip
    params[:host] = matches[4].strip
    params[:dbname] = matches[5].strip
    params
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