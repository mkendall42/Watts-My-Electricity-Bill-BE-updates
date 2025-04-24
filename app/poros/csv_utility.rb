class CsvUtility
  attr_reader :zipcode, 
              :state, 
              :res_rate, 
              :ind_rate, 
              :comm_rate

  def initialize(zipcode, state, res_rate, ind_rate, comm_rate)
    @zipcode = zipcode
    @state = state
    @res_rate = res_rate
    @ind_rate = ind_rate
    @comm_rate = comm_rate
  end

end
