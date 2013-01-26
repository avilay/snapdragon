$: << File.expand_path(File.dirname(__FILE__) + "/components")
$: << File.expand_path(File.dirname(__FILE__) + "/models")
require 'sinatra'
require 'sinatra/reloader'
require 'digest/sha2'
require 'oauth2_client'
require 'user'
require 'data_store'
require 'bookmark_store'
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

  def reset_session
    session[:authenticated] = false
    session[:after_auth_call] = request.path_info
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
      @bs.add_or_get_user(@user)
      @pinned = @bs.get_pinned_bookmarks
    rescue
      reset_session
    end
  else    
    reset_session
  end  
end

get '/home/debug' do
  @dvals = {}
  if development?
    @dvals['env'] = 'dev'
  elsif test?
    @dvals['env'] = 'test'
  elsif production?
    @dvals['env'] = 'prod'
  else
    @dvals['env'] = 'udefined'
  end
  @dvals['app_id'] = settings.app_id
  @dvals['app_secret'] = settings.app_secret
  @dvals['auth_done'] = settings.auth_done
  @dvals['dbname'] = settings.dbname
  @dvals['dbuser'] = settings.dbuser
  @dvals['dbpwd'] = settings.dbpwd

  erb :'home/debug', :layout => :layout_home
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
    #status, headers, body = call! env.merge("PATH_INFO" => next_page)
    #[status, headers, body]
    redirect to(next_page)
  end
end

get '/home/' do
  @login_url = OAuth2Client.new(settings).login_url
  erb :'home/index', :layout => :layout_home
end

get '/bookmarks/' do
  @bookmarks = @bs.get_bookmarks.paginate(:page => params[:page], :per_page => settings.links_per_page)  
  erb :'bookmarks/list'
end

get '/bookmarks/new' do
  @heading = 'Bookmark New Page'
  @next = '/bookmarks/next'
  erb :'new1'
end

get '/bookmarks/next' do  
  @bm = @bs.add_or_get_bookmark(params[:url])
  if @bm.errors.count == 0
    @next = "/bookmarks/#{@bm.id}/edit"
    @button_name = "Add"
    if params[:popup]
      session[:popup] = true
      erb :'new2', :layout => :layout_popup
    else   
      erb :'new2'
    end
  else
    (session[:errors] ||= []).push(*@bm.errors)
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

get '/bookmarks/:id/edit' do
  @bm = @bs.get_bookmark(Integer(params[:id]))
  if @bm.errors.count == 0
    @next = "/bookmarks/#{@bm.id}/edit"
    @button_name = "Edit"
    erb :'new2'  
  else
    (session[:errors] ||= []).push(*@bm.errors)
    redirect back
  end
end


get '/bookmarks/:id/pin' do
  bm = @bs.update_bookmark(Bookmark.new('id' => Integer(params[:id]), 'is_pinned' => true))
  if bm.errors.count == 0
    (session[:notices] ||= []) << 'Bookmark successfully pinned.'    
  else
    (session[:errors] ||= []).push(*@bm.errors)    
  end
  redirect back
end

get '/bookmarks/:id/delete' do
  @bs.delete_bookmark(params[:id])
  (session[:notices] ||= []) << 'Bookmark deleted.'    
  redirect to('/bookmarks/')
end

get '/bookmarks/unpin' do
  erb :'unpin'
end

post '/bookmarks/unpin' do
  params.keys.each do |k|
    @bs.update_bookmark(Bookmark.new('id' => Integer(k), 'is_pinned' => false))  
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

get '/debug' do
  params.keys.each do |k|
    logger.info("#{k} = #{params[k].inspect}")
  end
end


#######################

get '/links/unpin' do
  erb :'unpin'
end

get '/feeds/' do
  erb :'feeds/list'
end

get '/feeds/:id' do
  erb :'feeds/show'
end

get '/feeds/:id/edit' do
  erb :'feeds/edit'
end

get '/feeds/:id/items/' do
  erb :'feeds/items'
end




