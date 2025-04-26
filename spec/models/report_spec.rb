require "rails_helper"

RSpec.describe Report, type: :model do
  describe "relationships" do
    it { should have_one(:user).through(:user_report) }
  end
  
  before(:each) do
    #Create a few users
    @user1 = User.create!(username: "jbickler", id: 1)
    @user2 = User.create!(username: "jbloom", id: 2)
    #Create a few reports (these will clearly need more info - DB migration - later)
    @report1 = Report.create!(nickname: "residence 1", energy_consumption: 1219, energy_cost: 461)
    @report2 = Report.create!(nickname: "residence 2", energy_consumption: 1800, energy_cost: 850)
    @report3 = Report.create!(nickname: "residence 1", energy_consumption: 2550, energy_cost: 1284)
    @report4 = Report.create!(nickname: "residence 2", energy_consumption: 2663, energy_cost: 1699)
    @report5 = Report.create!(nickname: "residence 3", energy_consumption: 2663, energy_cost: 1699)
    @report6 = Report.create!(nickname: "residence 4", energy_consumption: 2663, energy_cost: 1699)
    #Associate 'em:
    @user_report1 = UserReport.create!(user_id: @user1.id, report_id: @report1.id)
    @user_report2 = UserReport.create!(user_id: @user1.id, report_id: @report2.id)
    @user_report3 = UserReport.create!(user_id: @user2.id, report_id: @report3.id)
    @user_report4 = UserReport.create!(user_id: @user2.id, report_id: @report4.id)
    @user_report5 = UserReport.create!(user_id: @user2.id, report_id: @report5.id)
    @user_report6 = UserReport.create!(user_id: @user1.id, report_id: @report6.id)
  end

  describe "queries / methods" do
    it "correctly determines uniqueness for given user (ingores another user's dpulicate)" do
      expect(Report.is_unique_nickname?("residence 3", @user1.id)).to eq(true)
      expect(Report.is_unique_nickname?("residence 4", @user2.id)).to eq(true)
    end

    it "correctly identifies duplicate for same user" do
      expect(Report.is_unique_nickname?("residence 4", @user1.id)).to eq(false)
      expect(Report.is_unique_nickname?("residence 3", @user2.id)).to eq(false)
    end
  end

end
