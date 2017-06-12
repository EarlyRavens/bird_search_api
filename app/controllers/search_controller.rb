class SearchController < ApplicationController
  include SearchHelper
  def query
    params["business"] = "korean"
    params["location"] = "94105"
    @start_time = Time.now
    @potential_clients = []
    @processing_time = 0

    @yelp_businesses = query_yelp_api(params)
    @mechanize = Mechanize.new

    @yelp_business_threads = @yelp_businesses.map{|business| Thread.new{evaluate(business)}}
    @yelp_business_threads.each {|thread| thread.join}
    @response_time = Time.now - @start_time

    render json: {data: @potential_clients, quote: random, response_time: @response_time, processing_time: @processing_time}.to_json
  end
end
