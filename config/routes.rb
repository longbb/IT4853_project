Rails.application.routes.draw do
  get "crawl", to: "crawler#crawl"
end
