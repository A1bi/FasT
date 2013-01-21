FasT::Application.routes.draw do
  get "geschichte" => "history#index"

  get "g%C3%A4stebuch/neu" => "gbook#new", :as => "gbook_new"
  post "gbook/create"
  get "g%C3%A4stebuch(/:page)" => "gbook#entries", :as => "gbook_entries"

  root :to => 'welcome#index'

end
