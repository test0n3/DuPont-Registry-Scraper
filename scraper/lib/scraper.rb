# frozen_string_literal: true

require 'nokogiri'
require 'rest-client'
require 'httparty'
require 'byebug'
require 'pry'

# class Scraper, capture data from specific URL and captures relevant info.
class Scraper
  attr_reader :url, :make, :module

  def initialize(make, model)
    @make = make.capitalize
    @model = model.capitalize
    @url = "https://www.dupontregistry.com/autos/results/#{make}/#{model}/for-sale"
           .sub(' ', '--')
  end

  def parse_url(url)
    unparsed_page = HTTParty.get(url)
    Nokogiri::HTML(unparsed_page)
  end

  def scrape
    parsed_page = parse_url(@url)
    # Nokogiri object containing all cars on a given page
    cars = parsed_page.css('div.searchResults')
    # counts the number of cars on each page, should be 10
    per_page = cars.count
    total_listings = parsed_page
                     .css('#mainContentPlaceholder_vehicleCountWithin')
                     .text.to_i
    total_pages = self.get_number_of_pages(total_listings, per_page)

    first_page = create_car_hash(cars)
    all_other = build_full_cars(total_pages)
    first_page + all_other.flatten
    # binding.pry
  end
  binding.pry
  0

  # creates a hash with the values we need from ourparsed car object
  def create_car_hash(car_obj)
    car_obj.map do |car|
      {
        year: car.css('a')
                 .children[0]
                 .text[0..4]
                 .strip
                 .to_i,
        name: @make,
        model: @model,
        price: car.css('.cost')
                  .children[1]
                  .text.sub(',', '')
                  .to_i,
        link: "https://www.dupontregistry.com/#{car.css('a')
                                                   .attr('href')
                                                   .value}"
      }
    end
  end

  # gets URLs of all pages, not just the first page
  def get_all_page_url(array_of_ints)
    array_of_ints.map do |number|
      @url + "pagenum=#{number}"
    end
  end

  # finds how many pages of listings exist
  def get_number_of_pages(listings, cars_per_page)
    a = listings % cars_per_page
    if a.zero?
      listings / cars_per_page
    else
      listings / cars_per_page + 1
    end
  end

  # builds an array of car hashes for each page of the listings,
  # starting on page 2
  def build_full_cars(number_of_pages)
    a = [*2..number_of_pages]
    all_page_urls = get_all_page_url(a)

    all_page_urls.map do |url|
      pu = parse_url(url)
      cars = pu.css('div.searchResults')
      create_car_hash(cars)
    end
  end
end
