# README

## Technology

- Ruby version 2.3.3
- Rails version 5.0.2
- Solr version 6.5.0

## Run example

- Open project folder:
```cd path_to_project_folder```
- Bundle:
```bundle install```
- Migrate db:
```bundle exec rake db:migrate```
- Run seed link:
```bundle exec rake db:seed```
- Start solr server:
```
cd path_to_solr_folder
./bin/solr start -e cloud
```
- Run server:
```
cd path_to_project_folder
rails s
```
- Crawl data: Open browser and go to this link
```
localhost:3000/crawl
```

- Run demo at this link:
```
localhost:3000/search
```
