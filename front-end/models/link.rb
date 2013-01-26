class Link
  attr_reader :id, :url, :title, :errors

  def initialize(params)
    @id = params['id']
    @url = params['url']
    @title = params['title']
  end
end