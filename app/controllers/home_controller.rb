class HomeController < ApplicationController
  BASE_URI = 'http://localhost:3000/api/v1'

  def index
    @list = build_list(3)
    raise
  end

  # def list_details(list_id)
  #   url = 'http://localhost:3000/api/v1/lists/' + list_id.to_s
  #   response = HTTParty.get(url)
  #   return response.parsed_response
  # end

  # def list_items(list_id)
  #   url = 'http://localhost:3000/api/v1/lists/' + list_id.to_s + '/items_by_section'
  #   response = HTTParty.get(url)
  #   return response.parsed_response
  # end

  # def sections(list_id)
  #   url = 'http://localhost:3000/api/v1/lists/' + list_id.to_s + '/sections'
  #   response = HTTParty.get(url)
  #   return response.parsed_response
  # end

  def build_list(list_id)
    list = {}

    details = get_list_details(list_id)
    list[:name]        = details["name"]
    list[:description] = details["description"]

    list[:sections] = get_list_sections(list_id)

    list[:sections].each do |section|
      section[:items] = get_section_items(section["id"])
    end

    return list
  end

  def get_list_details(list_id)
    url = BASE_URI + '/lists/' + list_id.to_s
    response = HTTParty.get(url)
    return response.parsed_response
  end

  def get_list_sections(list_id)
    url = BASE_URI + '/lists/' + list_id.to_s + '/sections'
    response = HTTParty.get(url)
    return response.parsed_response
  end

  def get_section_items(section_id)
    url = BASE_URI + '/list-sections/' + section_id.to_s + '/items'
    response = HTTParty.get(url)
    return response.parsed_response
  end
end

# to display list:
# => get list details
  # => get '/lists/:id'
# => get list_sections
  # => get 'lists/:id/sections'
# => for each list_section
  # => get list_section_items
    # => get 'list-sections/:id/items'
  # => subtotal section
# => calculate total weight of all list_sections_items
