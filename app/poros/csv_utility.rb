class CsvUtility
  attr_reader :zipcode, :state, :res_rate
  def initialize(zipcode, state, res_rate)
    @zipcode = zipcode
    @state = state
    @res_rate = res_rate
  end

end