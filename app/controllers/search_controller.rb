class SearchController < ApplicationController
  include SearchHelper
  def query
    params[:business] = "korean"
    params[:location] = "94105"
    @potential_clients = []

    @yelp_businesses = query_yelp_api(params)
    @mechanize = Mechanize.new

    @yelp_business_threads = @yelp_businesses.map{|business| Thread.new{evaluate(business)}}
    @yelp_business_threads.each {|thread| thread.join}

    render json: @yelp_businesses.to_json
  end
end
