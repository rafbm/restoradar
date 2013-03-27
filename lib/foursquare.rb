require 'httparty'
require 'ostruct'

module Foursquare
  class Error < StandardError; end

  include HTTParty

  base_uri 'https://api.foursquare.com/v2'

  def self.get(path, params)
    super path, query: params
  end

  METHODS = {
    search_venues: '/venues/search',
  }

  METHODS.each do |wrapper_method, path|
    define_singleton_method wrapper_method do |params|
      locale = params[:locale] == 'fr' ? 'fr' : 'en'
      Foursquare.headers 'Accept-Language' => locale

      filtered_params = params.dup
      filtered_params.delete(:locale)

      response = get(path, params)
      result = response['response']

      WrapperMethods.send(wrapper_method, result, params, headers)
    end
  end

  module WrapperMethods
    def self.search_venues(result, params = {}, headers = {})
      latitude, longitude = params[:ll].split(',').map(&:to_f)

      venues = result['venues']
      venues = venues.map { |v|
        category = v['categories'].first
        {
          id: v['id'],
          name: v['name'],
          category: category['shortName'],
          distance: v['location']['distance'],
          icon: "#{category['icon']['prefix']}bg_88#{category['icon']['suffix']}",
          latitude: v['location']['lat'],
          longitude: v['location']['lng'],
          location: "#{v['location']['lat']},#{v['location']['lng']}",
        }
      }
      venues = venues.sort_by { |v|
        v[:distance]
      }
      venues = venues.map { |v|
        OpenStruct.new(v)
      }
    end
  end

  module Categories
    Food = '4d4b7105d754a06374d81259'
  end
end
