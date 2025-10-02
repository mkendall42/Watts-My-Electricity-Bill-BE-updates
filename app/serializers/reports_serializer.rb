class ReportsSerializer
  def self.format_report_data(report)
    {
      nickname: report.nickname,
      energy_consumption: report.energy_consumption.to_f,
      cost: report.energy_cost.to_f,
      state: report.state,
      state_average: {
        residential: report.state_residential_avg,
        industrial: report.state_industrial_avg,
        commercial: report.state_commercial_avg,
      },
      zip_average: {
        residential: report.zip_residential_avg.to_f,
        industrial: report.zip_industrial_avg.to_f,
        commercial: report.zip_commercial_avg.to_f
      }
    }
  end

  def self.format_deleted_report_data(report, prior_user)
    {
      deleted_report: {
        nickname: report.nickname,
        id: report.id,
        associated_username: prior_user.username
      },
      num_remaining_reports: Report.all.length
    }
  end
end
