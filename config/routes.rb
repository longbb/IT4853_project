Rails.application.routes.draw do
  get "results", to: "search#result"
  get "crawl", to: "crawler#start"
  get "search", to: "search#search"
end
