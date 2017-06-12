class SearchController < ApplicationController
  include SearchHelper
  def query
    @potential_clients = []

    @yelp_businesses = query_yelp_api(params)
    @mechanize = Mechanize.new

    @yelp_business_threads = @yelp_businesses.map{|business| Thread.new{evaluate(business)}}
    @yelp_business_threads.each {|thread| thread.join}

    render json: {data: @potential_clients.to_json, quote: random}
  end
end
