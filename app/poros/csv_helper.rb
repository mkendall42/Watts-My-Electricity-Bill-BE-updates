require 'csv'

class CSVHelper
  attr_reader :data

  def self.utilityCSV(csv_data)
    @data = []
    CSV.foreach(csv_data, headers: true, header_converters: :symbol) do |row|
      data << CSV_Utility.new(
        row[:zip].to_i
        row[:state]
        row[:res_rate].to_f
      )
    end
    @data
  end

  def self.price_by_zip(zipcode)
    zip_data = @data.select { |area| area.zip == zipcode }
    return zip_data.res_rate
  end

  def self.price_by_state(state)
    state_data = @data.select { |area| area.state == state }
    state_total = state_data.sum { |area| area.res_rate }
    return state_total / state_data.length
  end

end