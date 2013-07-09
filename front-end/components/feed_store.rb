require 'data_store'
require 'feedzirra'

class FeedStore < DataStore

  def add_or_get_feed(feed_url)
    raise 'Cannot call this method without setting the user id' unless self.user_id
    url.strip!
    
    # Check if this is a valid url
    if URI.invalid?(feed_url)
      return Feed.new('errors' => ["#{feed_url} is not a valid url."])
    end    

    # Check if the user has already subscribed to this feed
    fds = @conn.exec(CHK_USR_FD, [self.user_id, feed_url])
    if fds.count == 1
      return Feed.new(fds.first)
    end

    # Check if this feed exists in the db, subscribe the user if it does
    fds = @conn.exec(CHK_FD, [feed_url])
    if fds.count == 1
      @conn.exec(INS_USR_FD, [self.user_id, fds.first['id'], Time.now, false])
      return Feed.new(fds.first)
    end

    # Fetch the feed, add it to the db, and subscribe the user
    feed = Feedzirra::Feed.fetch_and_parse(feed_url)
    return Feed.new('errors' => ["#{feed_url} is not a valid feed."]) unless feed
    web_url = feed.url
    title = feed.title
    description = feed.description
    last_updated_on = feed.last_modified
    is_pinned = false
    fid = @conn.exec(INS_FD, [feed_url, web_url, title, description, last_updated_on, is_pinned]).first['id']    
    # TODO: Add the items of this feed to the db    
    @conn.exec(INS_USR_FD, [self.user_id, fid, Time.now])
    Feed.new(@conn.exec(GET_FD_FOR_USR, [self.user_id, fid]).first) 
  end

  def get_feeds
    raise 'Cannot call this method without setting user id' unless self.user_id
    Feed.build(@conn.exec(GET_FDS_FOR_USR, [self.user_id]))
  end

  def get_feed(id)
  	raise 'Cannot call this method without setting user id' unless self.user_id
    fds = @conn.exec(GET_FD_FOR_USR, [self.user_id, id])
    if fds.count == 1
      Feed.new(fds.first)
    else
      Feed.new('errors' =>['User does not own the bookmark'])
    end
  end

  def get_pinned_feeds
  	raise 'Cannot call this method without setting user id' unless self.user_id
    Feed.build(@conn.exec(GET_PINNED_FDS_FOR_USR, [self.user_id]))
  end

  # def update_feed(proto)
  # 	raise 'Cannot call this method without setting user id' unless self.user_id
  #   fds = @conn.exec(GET_FD, [proto.id, self.user_id])
  #   return Feed.new('errors' =>['User does not own the feed']) unless fds.count == 1
  #   fd = fds.first
  #   new_description = proto.description || fd['description']    
  #   if proto.is_pinned.nil?
  #     new_is_pinned = fd['is_pinned']
  #   else
  #     new_is_pinned = proto.is_pinned
  #   end

  #   @conn.exec(EDIT_FD, [new_description, new_is_pinned, proto.id])
  #   return Feed.new(@conn.exec(GET_FD, [proto.id, self.user_id]).first)
  # end

  def delete_feed(id)
  	@conn.exec(DEL_FD, [self.user_id, id])
  end
  
end

