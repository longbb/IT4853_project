class SearchController < ApplicationController
  def search
    page = params[:page].present? ? params[:page] : 0
    per_page = 10
    start = per_page * page
    params[:query] = "test ebay"
    query = params[:query].split(" ").join("+")
    solr_url = "http://localhost:8983/solr/ebay_production/select?wt=json&indent=true&q=" +
      query + "&rows=" + per_page.to_s + "&start=" + start.to_s

    response = get_https_request solr_url
    @result = JSON.parse(response.body)
    number_result = @result["response"]["numFound"]

    render html: number_result.inspect
  end
end
