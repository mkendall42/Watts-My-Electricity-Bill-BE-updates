class EiaGateway

  
  def conn
    Faraday.new(url: 'https://api.eia.gov/v2') do |faraday|
      faraday.headers['Authorization'] = "Bearer #{ENV['eia_token']}"
    end
  end
end