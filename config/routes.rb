FasT::Application.routes.draw do
  # dates
  get "termine" => "dates#jedermann", :as => "dates"

  # theater
  get "theater" => "theater#index"
  get "theater/montevideo"
  get "theater/hexenjagd"
  get "theater/medicus"
  get "theater/phantasus"

  # info
  get "info" => "info#index"
  get "info/map"
  get "info/weather"

  # guestbook
  get "g%C3%A4stebuch/neu" => "gbook#new", :as => "gbook_new"
  post "gbook/create"
  get "g%C3%A4stebuch(/:page)" => "gbook#entries", :as => "gbook_entries"
  
  # static pages
  get "geschichte" => "static#history"
  get "impressum" => "static#impressum"
  get "satzung" => "static#satzung"
  get "agb" => "static#agb"

  root :to => 'static#index'

end
