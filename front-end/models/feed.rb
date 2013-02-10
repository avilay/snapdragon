class Feed
  attr_reader :id, :url, :title, :description, :web_url, :added_on
  attr_accessor :errors
  
  def initialize(params = nil)
    if params
      @id = params['id']
      @url = params['url']
      @title = params['title']
      @description = params['description']
      @web_url = params['web_url']
      @added_on = params['added_on']
      self.errors = param['errors']
    end
    self.errors ||= []
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