$: << File.expand_path(File.dirname(__FILE__) + "/components")
$: << File.expand_path(File.dirname(__FILE__) + "/models")
require 'sinatra'
require 'sinatra/reloader'
require 'digest/sha2'
require 'oauth2_client'
require 'user'
require 'data_store'
require 'bookmark_store'
require 'feed_store'
require 'will_paginate'
require 'will_paginate/array'
require 'will_paginate-bootstrap'

enable :sessions

configure do
  set :app_id, ENV['FB_APP_ID']
  set :app_secret, ENV['FB_APP_SECRET']
  set :host_name, ENV['HOSTNAME']
  set :auth_done, "http://#{ENV['HOSTNAME']}/home/authdone"
  set :conn_str, ENV['DATABASE_URL']
  set :state, Digest::SHA2.hexdigest(rand.to_s)
  set :links_per_page, 10    
end

helpers do
  def partial(page, options = {})
    erb page, options.merge!(:layout => false)
  end

  def set_flash
    @flash = {}
    @flash[:errors] = session[:errors] || []
    @flash[:notices] = session[:notices] || []
    session[:errors] = nil
    session[:notices] = nil
  end

  def reset_session(call_next)
    session[:authenticated] = false
    session[:after_auth_call] = call_next
    redirect OAuth2Client.new(settings).login_url  
  end
end

# All paths starting with home should be excluded from being authenticated
# Only paths that do not start with home should have this filter apply
before %r{^((?!/(home)|(css)|(img)|(js)/).)*$} do  
  set_flash
  if session[:authenticated]
    begin
      @user = session[:user]      
      @bs = BookmarkStore.new(settings.conn_str)
      @fs = FeedStore.new(settings.conn_str)
      @bs.add_or_get_user(@user)
      @fs.add_or_get_user(@user)
      @pinned_bookmarks = @bs.get_pinned_bookmarks
      @pinned_feeds = @fs.get_pinned_feeds
    rescue
      # TODO: Somehow log an error here
      #reset_session("/")
      raise
    end
  else    
    reset_session(request.path_info)
  end  
end

get '/home/authdone' do
  logger.info 'Inside /home/authdone'
  oclient = OAuth2Client.new(settings)  
  oclient.logger = logger
  if user = oclient.authenticate(params)
    logger.info 'user was authenticated'
    session[:user] = DataStore.new(settings.conn_str).add_or_get_user(User.new(user))
    session[:authenticated] = true
    next_page = session[:after_auth_call] || '/home/'
    logger.info "about to call #{next_page}"
    redirect to(next_page)
  end
end

# TODO: Find a good regex for both '/home/' and '/'
get '/' do
  redirect to('/home/')
end

get '/home/' do
  @login_url = OAuth2Client.new(settings).login_url
  erb :'home/index', :layout => :layout_home
end

get '/bookmarks/' do
  @bookmarks = @bs.get_bookmarks.paginate(:page => params[:page], :per_page => settings.links_per_page)  
  erb :'bookmarks/list'
end

get '/feeds/' do
  @feeds = @fs.get_feeds.paginate(:page => params[:page], :per_page => settings.links_per_page)
  erb :'feeds/list'
end

get '/bookmarks/new' do
  @heading = 'Bookmark New Page'
  @next = '/bookmarks/next'
  erb :'new'
end

get '/feeds/new' do
  @heading = 'Subscribe To Feed'
  @next = '/feeds/next'
  erb :'new'
end

get '/bookmarks/next' do  
  @bm = @bs.add_or_get_bookmark(params[:url])
  if @bm.errors.count == 0
    @next = "/bookmarks/#{@bm.id}/edit"
    @button_name = "Add"
    if params[:popup]
      session[:popup] = true
      erb :'bookmarks/edit', :layout => :layout_popup
    else   
      erb :'bookmarks/edit'
    end
  else
    (session[:errors] ||= []).push(*@bm.errors)
    redirect back
  end
end

get '/feeds/next' do  
  @fd = @fs.add_or_get_feed(params[:url])
  if @fd.errors.count == 0
    @next = "/feeds/#{@fd.id}/edit"
    @button_name = "Add"
    if params[:popup]
      session[:popup] = true
      erb :'feeds/edit', :layout => :layout_popup
    else   
      erb :'feeds/edit'
    end
  else
    (session[:errors] ||= []).push(*@fd.errors)
    redirect back
  end
end

post '/bookmarks/:id/edit' do
  bookmark = @bs.update_bookmark(Bookmark.new(params))
  if bookmark.errors.count == 0
    (session[:notices] ||= []) << 'Bookmark successfully added.'
    if session[:popup]
      session[:popup] = nil
      erb :'end', :layout => :layout_popup
    else
      redirect to('/bookmarks/')
    end
  else
    (session[:errors] ||= []).push(*bookmark.errors)
    redirect back
  end
end

post '/feeds/:id/edit' do
  feed = @fs.update_feed(Feed.new(params))
  if feed.errors.count == 0
    (session[:notices] ||= []) << 'Feed successfully added.'
    if session[:popup]
      session[:popup] = nil
      erb :'end', :layout => :layout_popup
    else
      redirect to('/feeds/')
    end
  else
    (session[:errors] ||= []).push(*feed.errors)
    redirect back
  end
end


get '/bookmarks/:id/edit' do
  @bm = @bs.get_bookmark(Integer(params[:id]))
  if @bm.errors.count == 0
    @next = "/bookmarks/#{@bm.id}/edit"
    @button_name = "Edit"
    erb :'bookmarks/edit'  
  else
    (session[:errors] ||= []).push(*@bm.errors)
    redirect back
  end
end

get '/feeds/:id/edit' do
   @fd = @fs.get_feed(Integer(params[:id]))
   if @fd.errors.count == 0
     @next = "/feeds/#{@fd.id}/edit"
     @button_name = "Edit"
     erb :'feeds/edit'  
   else
     (session[:errors] ||= []).push(*@fd.errors)
     redirect back
   end
end


get '/bookmarks/:id/pin' do
  bm = @bs.update_bookmark(Bookmark.new('id' => Integer(params[:id]), 'is_pinned' => true))
  if bm.errors.count == 0
    (session[:notices] ||= []) << 'Bookmark successfully pinned.'    
  else
    (session[:errors] ||= []).push(*bm.errors)    
  end
  redirect back
end

get '/feeds/:id/pin' do
  fd = @fs.update_feed(Feed.new('id' => Integer(params[:id]), 'is_pinned' => true))
  if fd.errors.count == 0
    (session[:notices] ||= []) << 'Feed successfully pinned.'    
  else
    (session[:errors] ||= []).push(*fd.errors)    
  end
  redirect back
end

get '/bookmarks/:id/delete' do
  @bs.delete_bookmark(params[:id])
  (session[:notices] ||= []) << 'Bookmark deleted.'    
  redirect to('/bookmarks/')
end

get '/feeds/:id/delete' do
  @fs.delete_feed(params[:id])
  (session[:notices] ||= []) << 'Feed unsubscribed.'    
  redirect to('/feeds/')
end

get '/links/unpin' do
  erb :'unpin'
end

post '/links/unpin' do
  params.keys.each do |k|
    logger.info("Unpinning #{k}")
    matches = %r{(bm|fd)_(\d+)}.match(k)
    if matches[1] == 'bm'
      @bs.update_bookmark(Bookmark.new('id' => Integer(matches[2]), 'is_pinned' => false))
    elsif matches[1] == 'fd'
      @fs.update_feed(Feed.new('id' => Integer(matches[2]), 'is_pinned' => false))      
    end
  end
  redirect to('/bookmarks/')
end

get '/bookmarks/:id' do
  @bm = @bs.get_bookmark(Integer(params[:id]))
  if @bm.errors.count == 0
    erb :'bookmarks/show'
  else
    (session[:errors] ||= []).push(*@bm.errors)
    redirect to('/bookmarks/')
  end
end

get '/feeds/:id' do
  @fd = @fs.get_feed(Integer(params[:id]))
  if @fd.errors.count == 0
    erb :'feeds/show'
  else
    (session[:errors] ||= []).push(*@fd.errors)
    redirect to('/feeds/')
  end
end

get '/debug' do
  params.keys.each do |k|
    logger.info("#{k} = #{params[k].inspect}")
  end
end

get '/feeds/:id/items/' do

  erb :'feeds/items'
end




