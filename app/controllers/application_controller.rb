class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  require "json"

  include HttpRequestHelper
  include ApplicationHelper
end
