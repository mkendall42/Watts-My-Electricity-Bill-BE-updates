class Report < ApplicationRecord
  has_one :user_report
  has_one :user, through: :user_report         #May be updated to many-to-many later

  validates :nickname, presence: true
  validates :energy_consumption, presence: true
  validates :energy_cost, presence: true

  def self.is_unique_nickname?(text)
    !Report.find_by(nickname: text)
  end
end
