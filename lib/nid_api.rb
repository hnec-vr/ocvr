class NidApi
  def self.get(nid)
    resp = Nestful.get("https://stats.ivote.ly/voter/#{nid}", {}, :auth_type => :basic, :user => ENV["NID_API_USERNAME"], :password => ENV["NID_API_PASSWORD"])
    return resp.decoded
    rescue Nestful::ResourceNotFound
        return nil
    rescue Errno::ETIMEDOUT, SocketError
        raise "Unable to connect to NID API"
  end
end
