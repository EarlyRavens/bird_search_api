class SearchController < ApplicationController
  include SearchHelper
  def query
    @start_time = Time.now
    @potential_clients = []
    @procesing_time = 0

    @yelp_businesses = query_yelp_api(params)
    @mechanize = Mechanize.new

    @yelp_business_threads = @yelp_businesses.map{|business| Thread.new{evaluate(business)}}
    @yelp_business_threads.each {|thread| thread.join}
    @response_time = Time.now - @start_time

    render json: {data: @potential_clients, quote: random, response_time: @response_time, virtual_time: @response_time}.to_json
  end
end
