class Feed
  attr_reader :id, :feed_url, :web_url, :title, :description
  attr_reader :crawled_at, :last_updated_on, :added_on, :is_pinned
  attr_accessor :errors  
  
  def initialize(params = nil)
    if params
      @id = params['id']
      @feed_url = params['feed_url']
      @web_url = params['web_url']
      @title = params['title']
      @description = params['description']
      @crawled_at = params['crawled_at']
      @last_updated_on = params['last_updated_on']
      @added_on = params['added_on']
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
  
  def Feed.build(fs)
    feeds = []
    fs.each { |f| feeds << Feed.new(f) }
    feeds
  end
  
  def ===(that)
    if self.id == that.id &&
      self.url == that.url &&
      self.title == that.title &&
      self.description == that.description &&
      self.web_url == that.web_url &&
      self.errors == that.errors
      true
    else
      false
    end
  end

end