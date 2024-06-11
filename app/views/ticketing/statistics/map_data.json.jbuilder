# frozen_string_literal: true

json.locations @locations do |location|
  json.call(location, :postcode, :cities, :districts, :orders)
  json.coordinates location[:coordinates].to_a.reverse
end
