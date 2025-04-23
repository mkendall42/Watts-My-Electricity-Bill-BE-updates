class EiaGateway
  def report_details
    response = Faraday.get("https://api.eia.gov/v2/electricity/retail-sales/data/") do |req|
      req.params['api_key'] = ENV['eia_api_key']
      req.params['frequency'] = 'monthly'
      req.params['data[0]'] = 'price'
      req.params['sort[0][column]'] = 'period'
      req.params['sort[0][direction]'] = 'desc'
      req.params['offset'] = '0'
      req.params['length'] = '5000'
    end

    JSON.parse(response.body, symbolize_names: true)
  end
end