require 'data_store'

class BookmarkStore < DataStore
  
  def add_or_get_bookmark(url)
    raise 'Cannot call this method without setting the user id' unless self.user_id
    url.strip!
    
    # Check if this is a valid url
    if URI.invalid?(url)
      return Bookmark.new('errors' => ["#{url} is not a valid url."])
    end    

    # Check if this url was already bookmarked by the user    
    bms = @conn.exec(CHK_BM, [self.user_id, url])
    if bms.count == 1
      return Bookmark.new(bms.first)
    end

    link = add_or_get_link(url)    
    bid = @conn.exec(INS_BM, [link['title'], Time.now, false, self.user_id, Integer(link['id'])]).first['id']    
    bm = Bookmark.new(@conn.exec(GET_BM, [bid, self.user_id]).first)
    bm
  end

  # TODO: Add test cases where only parts of the prototype are specified
  def update_bookmark(proto)
    raise 'Cannot call this method without setting user id' unless self.user_id
    bms = @conn.exec(GET_BM, [proto.id, self.user_id])
    return Bookmark.new('errors' =>['User does not own the bookmark']) unless bms.count == 1
    bm = bms.first
    new_name = proto.name || bm['name']
    new_notes = proto.notes || bm['notes']
    if proto.is_pinned.nil?
      new_is_pinned = bm['is_pinned']
    else
      new_is_pinned = proto.is_pinned
    end

    @conn.exec(EDIT_BM, [new_name, new_notes, new_is_pinned, proto.id])
    return Bookmark.new(@conn.exec(GET_BM, [proto.id, self.user_id]).first)
  end

  def get_bookmarks
    raise 'Cannot call this method without setting user id' unless self.user_id
    Bookmark.build(@conn.exec(GET_BMS, [self.user_id]))
  end

  def get_bookmark(id)
    raise 'Cannot call this method without setting user id' unless self.user_id
    bms = @conn.exec(GET_BM, [id, self.user_id])
    if bms.count == 1
      Bookmark.new(bms.first)
    else
      Bookmark.new('errors' =>['User does not own the bookmark'])
    end
  end

  # TODO: Write unit tests
  def get_pinned_bookmarks
    raise 'Cannot call this method without setting user id' unless self.user_id
    Bookmark.build(@conn.exec(GET_PINNED, [self.user_id]))
  end

  # TODO: write unit tests
  def delete_bookmark(id)    
    @conn.exec(DEL_BM, [self.user_id, id])
  end

end