namespace :one_off do
  task run: :environment do
    postcodes = Ticketing::Web::Order.select(:plz).distinct.pluck(:plz)

    postcodes.each do |postcode|
      Ticketing::GeolocatePostcodeJob.set(wait: rand(120).seconds)
                                     .perform_later(postcode)
    end
  end
end
