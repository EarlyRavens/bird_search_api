class SearchController < ApplicationController
  include SearchHelper
  def query
    start_time = Time.now

    @potential_clients = []

    @yelp_businesses = query_yelp_api(params)
    @mechanize = Mechanize.new

    @yelp_business_threads = @yelp_businesses.map{|business| Thread.new{evaluate(business)}}
    @yelp_business_threads.each {|thread| thread.join}

    @processing_time = Time.now - start_time

    thread1 = Thread.new {reset_server}
    thread2 = Thread.new {
      p "Rendering data"
      render json: {data: @potential_clients, quote: random, processing_time: @processing_time}.to_json}

    thread1.join
    thread2.join
  end
end
