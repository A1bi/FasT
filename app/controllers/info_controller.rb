class InfoController < ApplicationController
  
  require 'open-uri'
  
  caches_action :weather, :expires_in => 30.minutes
  
  def index
  end
  
  def map
  end
  
  def weather
    # Yahoo Weather
     
    locId = 664471
    url = "http://weather.yahooapis.com/forecastrss?u=c&w=" + locId.to_s
    
    data = Hash.from_xml open(url).read
    
    item = data['rss']['channel']['item']
    forecast = item['forecast'][0]
    condition = item['condition']
    
    # probability of precipitation (rain) from different source

    url = "http://www.worldweatheronline.com/Kaisersesch-weather/Rheinland-Pfalz/DE.aspx"
    
    raw = open(url).read.scan /<div class="outlook_left">P.O.P:<\/div><div class="outlook_right">([0-9]+)%<\/div>/is
    pop = ""
    #pop = raw[0][0] if raw

    weather = {
      low: forecast['low'],
      high: forecast['high'],
      daytime: (Time.current.hour > 6 && Time.current.hour < 21) ? "d" : "n",
      pop: pop,
      date: Time.parse(condition['date']).to_s(:time)
    }
    
    ["temp", "text", "code"].each do |field|
      weather[field] = condition[field]
    end
    
    response = {
      error: "",
      data: weather
    }
    
    render :json => response
  end
end
