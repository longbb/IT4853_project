module HttpRequestHelper
  def post_https_request url, params=nil, header=nil
    conn = Faraday.new()

    res = conn.post do |req|
      req.url url
      req["Accept"] = "application/json"
      req["Content-Type"] = "application/json"
      if header.present?
        header.each do |key, value|
          req[key.to_s] = value.to_s
        end
      end
      if params.present?
        req.body = params
      end
    end
    return res
  end

  def get_https_request url, params=nil, header=nil
    conn = Faraday.new()

    res = conn.get do |req|
      req.url url
      req["Accept"] = "application/json"
      req["Content-Type"] = "application/json"
      if header.present?
        header.each do |key, value|
          req[key.to_s] = value.to_s
        end
      end
      if params.present?
        params.each do |key,value|
          req.params[key.to_s] = value.to_s
        end
      end
    end
    return res
  end
end
