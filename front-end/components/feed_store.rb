require 'data_store'
require 'feedzirra'

class FeedStore < DataStore

  def add_or_get_feed(url)
    raise 'Cannot call this method without setting the user id' unless self.user_id
    url.strip!
    
    # Check if this is a valid url
    if URI.invalid?(url)
      return Feed.new('errors' => ["#{url} is not a valid url."])
    end    

    # Check if this feed was already subscribed by the user    
    fds = @conn.exec(CHK_FD, [self.user_id, url])
    if fds.count == 1
      return Feed.new(fds.first)
    end

    feed = Feedzirra::Feed.fetch_and_parse(url)
    return Feed.new('errors' => ["#{url} is not a valid feed."]) unless feed

    link = add_or_get_link(url) do |url|
      title = feed.title || ''      
    end
    
    description = feed.description || ''
    
    fid = @conn.exec(INS_FD, [description, Time.now, Time.now, false, self.user_id, Integer(link['id'])]).first['id']    
    Feed.new(@conn.exec(GET_FD, [fid, self.user_id]).first)    
  end

  def get_feeds
    raise 'Cannot call this method without setting user id' unless self.user_id
    Feed.build(@conn.exec(GET_FDS, [self.user_id]))
  end

  def get_feed(id)
  	raise 'Cannot call this method without setting user id' unless self.user_id
    fds = @conn.exec(GET_FD, [id, self.user_id])
    if fds.count == 1
      Feed.new(fds.first)
    else
      Feed.new('errors' =>['User does not own the bookmark'])
    end
  end

  def get_pinned_feeds
  	raise 'Cannot call this method without setting user id' unless self.user_id
    Feed.build(@conn.exec(GET_PINNED_FDS, [self.user_id]))
  end

  def update_feed(proto)
  	raise 'Cannot call this method without setting user id' unless self.user_id
    fds = @conn.exec(GET_FD, [proto.id, self.user_id])
    return Feed.new('errors' =>['User does not own the feed']) unless fds.count == 1
    fd = fds.first
    new_description = proto.description || fd['description']    
    if proto.is_pinned.nil?
      new_is_pinned = fd['is_pinned']
    else
      new_is_pinned = proto.is_pinned
    end

    @conn.exec(EDIT_FD, [new_description, new_is_pinned, proto.id])
    return Feed.new(@conn.exec(GET_FD, [proto.id, self.user_id]).first)
  end

  def delete_feed(id)
  	@conn.exec(DEL_FD, [self.user_id, id])
  end
  
end

