class EiaGateway
  BASE_PATH = '/electricity/retail-sales/data/'

  def report_details
    get_url(BASE_PATH, {
      api_key: ENV['eia_api_key'],
      frequency: 'monthly',
      'data[0]': 'price',
      'sort[0][column]': 'period',
      'sort[0][direction]': 'desc',
      offset: '0',
      length: '5000'
    })
  end

  def get_url(path, params = {})
    response = conn.get(path) do |req|
      req.params.update(params)
    end

    JSON.parse(response.body, symbolize_names: true)
  end

  def conn
    Faraday.new(url: 'https://api.eia.gov/v2') do |faraday|
      faraday.headers['Content-Type'] = 'application/json'
    end
  end
end