class Feed
  attr_reader :id, :url, :title, :last_updated_on, :added_on
  attr_accessor :description, :errors  
  
  def initialize(params = nil)
    if params
      @id = params['id']
      @url = params['url']
      @title = params['title']
      @description = params['description']
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