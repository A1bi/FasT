FasT::Application.routes.draw do
  get "termine" => "dates#jedermann", :as => "dates"

  get "theater" => "theater#index"
  get "theater/montevideo"
  get "theater/hexenjagd"
  get "theater/medicus"
  get "theater/phantasus"

  get "info" => "info#index"
  get "info/map"
  get "info/weather"

  get "geschichte" => "history#index"

  get "g%C3%A4stebuch/neu" => "gbook#new", :as => "gbook_new"
  post "gbook/create"
  get "g%C3%A4stebuch(/:page)" => "gbook#entries", :as => "gbook_entries"

  root :to => 'welcome#index'

end
