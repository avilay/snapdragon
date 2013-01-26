require 'open-uri'
require 'nokogiri'

module URI
  def URI.valid?(url)
    begin
      URI.parse(url)
      true
    rescue InvalidURIError
      false
    end
  end

  def URI.invalid?(url)
    !valid?(url)
  end
end

module SdHelpers

  def SdHelpers.title(url)
    begin
        uri = URI.parse(url)
        title = Nokogiri::HTML(uri.open).title
        title.strip!
        title.gsub!(%r{\s+}, ' ')
      rescue Exception
        title = ''  
      end
      title
  end

end