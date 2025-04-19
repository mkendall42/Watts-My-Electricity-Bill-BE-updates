class EnergyInfo
  #Santizes / standardizes external API data, and provides calculations/functionality
  attr_reader :residence_name, :energy_consumption, :cost

  def initialize(user_search_data)
    #Assume very simple clean structure for now.  THIS WILL CHANGE LATER.
    @residence_name = user_search_data[:nickname]
    @residence_type = user_search_data[:residence_type]
    @num_residents = user_search_data[:num_residents]
    @efficiency_index = user_search_data[:efficiency_level]
    @coordinates = {
      latitude: user_search_data[:latitude],
      longitude: user_search_data[:longitude]
    }
    @zip_code = 0         #Determine/associate later (API call - might be outside MVP too)

    #Set to dummy values for now.  WILL CHANGE LATER.
    @rate = nil
    @energy_consumption = 2500
    @cost = 380

    #NOTE: calculate energy consumption later, AFTER the API call is complete
    #(this will also update some instance vars, like commented below for reminders)
    # @rate = api_response_json[:rate]
    # @energy_consumption = calculate_energy()
    # @cost = @rate * @energy_consumption

    #If any core parameter is missing, will need to check / raise exception or error
    #Maybe move controller verification into here?

  end

end