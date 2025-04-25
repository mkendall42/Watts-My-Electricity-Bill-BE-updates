# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
@user1 = User.create!(username: "jbickler")
@user2 = User.create!(username: "jbloom")
@user3 = User.create!(username: "mkendall")
@user4 = User.create!(username: "plittle")
@user5 = User.create!(username: "jason")

@report1 = Report.create!(
    nickname: "House",
    energy_consumption: 234,
    energy_cost: 74.39,
    state: "CO",
    state_residential_avg: 12,
    state_industrial_avg: 22,
    state_commercial_avg: 12,
    zip_residential_avg: 0.01,
    zip_industrial_avg: 0.02,
    zip_commercial_avg: 0.02,
)

@report2 = Report.create!(
  nickname: 'Summer Cooling',
  energy_consumption: 620,
  energy_cost: 88.50,
  state: "CA",
  state_residential_avg: 12,
  state_industrial_avg: 22,
  state_commercial_avg: 12,
  zip_residential_avg: 0.01,
  zip_industrial_avg: 0.02,
  zip_commercial_avg: 0.02,
)

@report3 = Report.create!(
  nickname: "Bob’s Bill",
  energy_consumption: 300,
  energy_cost: 39.99,
  state: "CA",
  state_residential_avg: 12,
  state_industrial_avg: 22,
  state_commercial_avg: 12,
  zip_residential_avg: 0.01,
  zip_industrial_avg: 0.02,
  zip_commercial_avg: 0.02,
)

UserReport.create!(user: @user2, report: @report3)
UserReport.create!(user: @user1, report: @report1)
UserReport.create!(user: @user1, report: @report2)
