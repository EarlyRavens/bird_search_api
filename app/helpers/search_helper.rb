module SearchHelper
  CLIENT_PAGE_TIME_LIMIT = 5
  MAXIMUM_TITLE_SCORE = 15
  MAXIMUM_META_SCORE = 15
  MAXIMUM_HEADING_SCORE = 5
  SEO_MINIMUM_SCORE = 14
  GOOGLE_API_TIME_LIMIT = 12
  MAXIMUM_SPEED_SCORE = 25
  MAXIMUM_USABILITY_SCORE = 45
  MAXIMUM_GOOGLE_SCORE = 100.0
  MINIMUM_SUCCESS_BENCHMARK = 79

  def random
    quotes = ["The early bird gets the worm! - Mina", "There is an art to the process of problem solving - Mike Tarkington", "Efficiency Focused - it's always important to work smart in addition to working hard - Mike Tarkington", "Creative Solutions - even the most difficult challenges can be overcome with creativity and cleverness - Mike Tarkington", "You miss all the shots you don't take - Wayne Gretzky - Michael Scott", "Fart - Omar Cameron", "They Don't Think It Be Like It Is But It Do - Max Peiros", "Has Anyone Really Been Far Even as Decided to Use Even Go Want to do Look More Like? - Patrick Tangphao", "Fuck Elixir - Earl Sabal"]
    return quotes.sample
  end

  def query_yelp_api(form_params)
    HTTParty.get("https://api.yelp.com/v3/businesses/search?location=#{form_params[:location]}&term=#{form_params[:business]}", headers: {"Authorization" => "Bearer #{ENV['YELP_API_KEY']}"})['businesses']
  end

end
