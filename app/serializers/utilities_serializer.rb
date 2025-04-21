class UtilitiesSerializer
  def self.format_energy_data(data)
    {
      nickname: data.residence_name,
      energy_consumption: data.energy_consumption,
      cost: data.cost
    }
  end
end