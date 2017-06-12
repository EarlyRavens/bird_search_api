class SearchController < ApplicationController
  include SearchHelper
  def query
    params[:business] = "korean"
    params[:location] = "94105"
    @potential_clients = []

    @yelp_businesses = query_yelp_api(params)
    @mechanize = Mechanize.new

    render json: @yelp_businesses.to_json
  end
end
