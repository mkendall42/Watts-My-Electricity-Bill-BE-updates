class Report < ApplicationRecord
  has_one :user_report
  has_one :user, through: :user_report         #May be updated to many-to-many later

  validates :nickname, presence: true
  validates :energy_consumption, presence: true
  validates :energy_cost, presence: true

  def self.is_unique_nickname?(text, user_id)
    #Must be unique for a single user only
    return false if User.find(user_id).reports.where(nickname: text) != []
    return true
  end
end
