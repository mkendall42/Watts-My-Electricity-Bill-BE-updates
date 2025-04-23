require 'csv'

class CSVHelper
  def self.utilityCSV(csv_data)
    data = []
    CSV.foreach(csv_data, headers: true, header_converters: :symbol) do |row|
      data << CSV_Utility.new(
        row[:zip].to_i
        row[:state]
        row[:res_rate].to_f
      )
    end
    data
  end
end