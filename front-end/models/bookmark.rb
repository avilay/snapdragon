class Bookmark
  attr_reader :id, :url, :title, :added_on
  attr_accessor :name, :notes, :errors

  def initialize(params = nil)
    if params
      @id = params['id']
      @url = params['url']
      @title = params['title']
      @added_on = params['added_on']
      self.name = params['name']
      self.notes = params['notes']
      self.is_pinned = params['is_pinned']
      self.errors = params['errors']        
    end
    self.errors ||= []
  end

  def is_pinned
    @is_pinned
  end

  def is_pinned=(val)
    if val.is_a?(String)
      if val.downcase.start_with?("t") 
        @is_pinned = true
      else
        @is_pinned = false
      end
    else
      @is_pinned = val
    end
  end

  def Bookmark.build(bms)
    bookmarks = []
    bms.each { |bm| bookmarks << Bookmark.new(bm) }
    bookmarks
  end

  def ===(that)
    if self.id == that.id &&
      self.url == that.url &&
      self.title == that.title &&
      self.added_on == that.added_on &&
      self.name == that.name &&
      self.notes == that.notes &&
      self.is_pinned == that.is_pinned &&
      self.errors == that.errors
      true
    else
      false
    end
  end 

end