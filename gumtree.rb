require 'mechanize'
class Gumtree
  attr_reader :scraper

  BASE_URL = 'https://www.gumtree.com'

  def initialize(location="London")
    @location = location
    @scraper = Mechanize.new
  end

  def search(category, query, featured: true, urgent: true, sort_by: 'date')
    encoded_query = URI.encode(query)
    page = scraper.get("#{BASE_URL}/search?featured_filter=#{(!featured).to_s}&urgent_filter=#{!urgent.to_s}&sort=#{sort_by}&search_scope=false&photos_filter=false&search_category=#{category}&q=#{encoded_query}&search_location=#{@location}")
    listings = page.search('article.listing-maxi')
    listings.map do |listing|
      begin
        price = Integer(listing.search('.listing-price').text[2..-3])
      rescue
        next
      end
      url = listing.search('a.listing-link').first.attr('href')
      { 
        title: listing.search('.listing-title').text[1..-2],
        price: price,
        description: listing.search('p.listing-description').text.strip,
        location: listing.search('.listing-location').text.strip,
        url: "#{BASE_URL}#{url}",
        posted: listing.search('.listing-posted-date').text.strip.split("\n").last,
        id: Integer(url.split('/').last)
      }
    end.compact
  end
end
