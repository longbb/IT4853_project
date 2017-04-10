Rails.application.routes.draw do
  get "crawl", to: "crawler#crawl"
  get "search", to: "home#show"
  get "results", to: "home#index"
end
