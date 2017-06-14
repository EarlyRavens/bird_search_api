module SearchHelper
  CLIENT_PAGE_TIME_LIMIT = 5
  SEO_MINIMUM_SCORE = 14
  GOOGLE_API_TIME_LIMIT = 12
  MAXIMUM_GOOGLE_SCORE = 100.0
  MINIMUM_SUCCESS_BENCHMARK = 79
  MAXIMUM_YELP_SCRAPE = 50

  QUOTES = ["The early bird gets the worm! - Mina", "There is an art to the process of problem solving - Mike Tarkington", "Efficiency Focused - it's always important to work smart in addition to working hard - Mike Tarkington", "Creative Solutions - even the most difficult challenges can be overcome with creativity and cleverness - Mike Tarkington", "You miss all the shots you don't take - Wayne Gretzky - Michael Scott", "Fart - Omar Cameron", "They Don't Think It Be Like It Is But It Do - Max Peiros", "Has Anyone Really Been Far Even as Decided to Use Even Go Want to do Look More Like? - Patrick Tangphao", "We did the thing - Earl Sabal", "That's Amazing! - Helen Khumthong"]

  def random
    return QUOTES.sample
  end

  def query_yelp_api(form_params)
    HTTParty.get("https://api.yelp.com/v3/businesses/search?location=#{form_params[:location]}&term=#{form_params[:business]}&limit=#{MAXIMUM_YELP_SCRAPE}", headers: {"Authorization" => "Bearer #{ENV['YELP_API_KEY']}"})['businesses']
  end

  def evaluate(business)

    business_page_dom = get_page_dom(business)

    if has_a_url?(business_page_dom)
      url = client_page(business_page_dom)
      begin
        seo_points = timeout_scrape_client_page(url)
        if seo_score_filter(seo_points)
          response = timeout_query_google_api(http_url)
          page_score = calculate_page_score(response, seo_points)
          add_potential_client(business) if failed_test(page_score)
        else
          add_potential_client(business)
        end

      rescue
        "Business skipped."
      end

    else
      add_potential_client(business)
    end
  end

  private

  def get_page_dom(business)
    @mechanize.get(business['url'])
  end

  def has_a_url?(dom)
    business_url(dom) ? true : false
  end

  def business_url(dom)
    return dom.css('.biz-website a').last
  end

  def client_page(dom)
    return business_url(dom).text
  end

  def timeout_scrape_client_page(long_url)
    Timeout::timeout(CLIENT_PAGE_TIME_LIMIT) {HTTParty.get("http://earlybird-extractor.herokuapp.com/api/seoscore?business=#{long_url}")["score"]}
  end

  def seo_score_filter(score)
    return score > SEO_MINIMUM_SCORE
  end

  def timeout_query_google_api(url)
    Timeout::timeout(GOOGLE_API_TIME_LIMIT) {HTTParty.get("https://www.googleapis.com/pagespeedonline/v2/runPagespeed?url=#{url}&strategy=mobile&key=#{ENV['SPEED_API_KEY']}")}
  end

  def calculate_page_score(google_response, points_from_seo)
    speed_score = MAXIMUM_SPEED_SCORE * (google_response["ruleGroups"]["SPEED"]["score"]/MAXIMUM_GOOGLE_SCORE)
    usability_score = MAXIMUM_USABILITY_SCORE * (google_response["ruleGroups"]["USABILITY"]["score"]/MAXIMUM_GOOGLE_SCORE)

    return speed_score + usability_score + points_from_seo
  end

  def add_potential_client(client)
    @potential_clients << client
  end

  def failed_test(score)
    return score < MINIMUM_SUCCESS_BENCHMARK
  end

  def reset_server
    puts "Resetting Server in 3"
    sleep 1
    puts "Resetting Server in 2"
    sleep 1
    puts "Resetting Server in 1"
    sleep 1
    puts "Resetting Server Now:"
    HTTParty.delete("https://api.heroku.com/apps/threadraven/dynos", headers: {"Authorization" => "Bearer a17504ec-bd05-4f72-8cdb-da9c9a233172", "Accept" => "application/vnd.heroku+json; version=3"})
  end
end
