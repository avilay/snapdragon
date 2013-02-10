require 'data_store'

class FeedStore < DataStore

  def get_feeds
    raise 'Cannot call this method without setting user id' unless self.user_id
    Feed.build(@conn.exec(GET_FDS, [self.user_id]))
  end
  
end