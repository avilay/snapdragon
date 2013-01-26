class Feed

	attr_reader :id, :url, :title, :last_updated_on, :number_of_items, :number_of_unread_items
	attr_accessor :name, :notes, :is_pinned, :errors

	def initialize(params)
		@id = params['link_id']
	    @url = params['url']
	    @title = params['title']
	    @last_updated_on = params['last_updated_on']
		@number_of_items = params['last_updated_on']	    
	    @number_of_unread_items = params['number_of_unread_items']
	    self.name = params['name']
	    self.notes = params['notes']
	end
end