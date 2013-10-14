class NidApi
  def self.get(nid)
    resp = Nestful.get("https://stats.ivote.ly/voter/#{nid}", {}, :auth_type => :basic, :user => ENV["NID_API_USERNAME"], :password => ENV["NID_API_PASSWORD"])
    return resp.decoded
    rescue Nestful::ResourceNotFound
    nil
  end
end
