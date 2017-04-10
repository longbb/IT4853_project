Rails.application.routes.draw do
  get "search_template", to: "home#show"
  get "results", to: "home#index"
  get "crawl", to: "crawler#start"
  get "search", to: "search#search"
end
