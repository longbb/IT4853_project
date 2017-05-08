class SearchController < ApplicationController
  def search
  end

  def result
    @current_page = params[:page].present? ? params[:page] : 0
    per_page = 5
    start = @current_page.to_i * per_page
    query = params[:query].split(" ").join("+")
    solr_url = "http://localhost:8983/solr/ebay_production/select?wt=json&indent=true&q=" +
      query + "&rows=" + per_page.to_s + "&start=" + start.to_s +
      + "&hl=on&hl.simple.pre=%3Cstrong%3E%3Cem%3E&hl.simple.post=%3C/em%3E%3C/strong%3E
      &hl.fl=title,itemCategories,description,supplier&hl.preserveMulti=true&hl.maxAnalyzedChars=-1&hl.fragsize=-1"

    response = get_https_request solr_url
    response_json = JSON.parse(response.body)
    @result = response_json["response"]
    @total_page = (@result["numFound"] / per_page) + 1
    @highlighting = response_json["highlighting"].to_h
  end
end
