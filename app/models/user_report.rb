class UserReport < ApplicationRecord
  belongs_to :user
  belongs_to :report
end