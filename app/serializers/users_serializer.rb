class UsersSerializer
  def self.format_users(users)
    users.map do |user|
      {
        id: user.id,
        username: user.username
      }
    end
  end

  def self.format_single_user(user)
    report_list = user.reports.map do |report|
      {
        nickname: report.nickname,
        id: report.id
      }
    end

    {
      username: user.username,
      num_reports: user.reports.length,
      reports: report_list
    }
  end

end
