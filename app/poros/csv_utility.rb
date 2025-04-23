class CSV_Utility
  attr_reader :zipcode, :state, :res_rate
  def initialize(zipcode, state, res_rate)
    @zipcode = zipcode
    @state = state
    @res_rate = res_rate
  end

  def self.zipcode_match(zip)
    return self if self.zipcode == zip
  end
end