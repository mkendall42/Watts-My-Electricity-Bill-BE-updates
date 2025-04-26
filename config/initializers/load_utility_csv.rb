Rails.application.config.to_prepare do
  path = Rails.root.join('db', 'data', 'iou_zipcodes_2023.csv')
  CsvHelper.utilityCSV(path.to_s)
  Rails.logger.info("✅ Utility CSV loaded at startup")
end

