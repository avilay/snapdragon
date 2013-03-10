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

