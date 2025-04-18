class Report < ApplicationRecord
  has_one :user_report
  has_one :user, through: :user_report         #May be updated to many-to-many later
end