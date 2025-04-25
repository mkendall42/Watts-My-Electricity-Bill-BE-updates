class ReportsSerializer
  def self.format_report_data(report)
    {
      #Will need to send more data for full ResultsContainer displaying
      #It must match the format of UtilitiesSerializer
      nickname: report.nickname,
      energy_consumption: report.energy_usage,
      cost: report.energy_cost
    }
  end

end