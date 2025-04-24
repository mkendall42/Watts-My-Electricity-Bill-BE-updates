class UtilitiesSerializer
  def self.format_energy_data(data)
    # this serializer might need slight alterations when we do the monthly calculations
    {
      nickname: data.residence_name,
      energy_consumption: data.energy_consumption,
      state: data.state,
      state_average: {
        residential: data.state_res_average[:price],
        industrial: data.state_ind_average[:price],
        commercial: data.state_comm_average[:price]
      },
      zip_average: {
        residential: data.zip_res_rate,
        industrial: data.zip_ind_rate,
        commercial: data.zip_comm_rate
      }
    }
  end

  def self.format_building_type(residential_data, industrial_data, commercial_data)
    {
      residential: residential_data,
      industrial: industrial_data,
      commercial: commercial_data
    }
  end
end
