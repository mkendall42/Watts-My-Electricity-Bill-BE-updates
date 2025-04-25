class UtilitiesSerializer
  def self.format_energy_data(data)
    # this serializer might need slight alterations when we do the monthly calculations
    {
      nickname: data.residence_name,
      energy_consumption: data.energy_consumption.to_f,
      cost: data.cost.to_f,
      state: data.state,
      state_average: {
        residential: data.state_res_average[:price].to_f / 100.0,
        industrial: data.state_ind_average[:price].to_f / 100.0,
        commercial: data.state_comm_average[:price].to_f / 100.0
      },
      zip_average: {
        residential: data.zip_res_rate.to_f,
        industrial: data.zip_ind_rate.to_f,
        commercial: data.zip_comm_rate.to_f
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
