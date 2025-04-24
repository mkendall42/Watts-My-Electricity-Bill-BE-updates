class EiaGateway
  def self.report_details(state)
    response = Faraday.get("https://api.eia.gov/v2/electricity/retail-sales/data/") do |req|
      req.params['api_key'] = ENV['eia_api_key']
      req.params['frequency'] = 'monthly'
      req.params['data[0]'] = 'price'
      req.params['sort[0][direction]'] = 'desc'
      req.params['sort[0][column]'] = 'period'
      req.params['offset'] = '0'
      req.params['length'] = '5'
      req.params['facets[stateid][]'] = state
    end

    full_response = JSON.parse(response.body, symbolize_names: true)
    residential = full_response[:response][:data].find { |data| data[:sectorName] == "residential" }
    industrial = full_response[:response][:data].find { |data| data[:sectorName] == "industrial" }
    commercial = full_response[:response][:data].find { |data| data[:sectorName] == "commercial" }

    UtilitiesSerializer.format_building_type(residential, industrial, commercial)
  end
end
