namespace :utility do
  desc "Load the utility CSV file into memory"
  task load_csv: :environment do
    path = Rails.root.join('db', 'data', 'iou_zipcodes_2023.csv')
    puts "Loading CSV from: #{path}"

    CsvHelper.utilityCSV(path.to_s)

    puts "✅ Utility CSV loaded!"
  end
end
