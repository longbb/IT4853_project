Rails.application.routes.draw do
  root "search#search"
  get "results", to: "search#result"
  get "crawl", to: "crawler#start"
  get "search", to: "search#search"
end
