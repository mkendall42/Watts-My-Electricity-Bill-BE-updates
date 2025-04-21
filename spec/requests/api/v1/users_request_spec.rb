require "rails_helper"

RSpec.describe "Users controller", type: :request do
  before(:each) do
    #Create a few users
    @user1 = User.create!(username: "jbickler")
    @user2 = User.create!(username: "jbloom")
    @user3 = User.create!(username: "mkendall")
    @user4 = User.create!(username: "plittle")
    #Create a few reports (these will clearly need more info - DB migration - later)
    @report1 = Report.create!(nickname: "van down by the river", energy_usage: 1219, energy_cost: 461)
    @report2 = Report.create!(nickname: "small apartment", energy_usage: 1800, energy_cost: 850)
    @report3 = Report.create!(nickname: "townhouse", energy_usage: 2550, energy_cost: 1284)
    @report4 = Report.create!(nickname: "5 floor narrow condo", energy_usage: 2663, energy_cost: 1699)
    @report5 = Report.create!(nickname: "4 bedroom house", energy_usage: 3903, energy_cost: 2497)
    @report6 = Report.create!(nickname: "vail mountain mansion", energy_usage: 7128, energy_cost: 5088)
    #Associate 'em:
    @user_report1 = UserReport.create!(user_id: @user1.id, report_id: @report3.id)
    @user_report1 = UserReport.create!(user_id: @user1.id, report_id: @report5.id)
    @user_report1 = UserReport.create!(user_id: @user2.id, report_id: @report6.id)
    @user_report1 = UserReport.create!(user_id: @user3.id, report_id: @report1.id)
    @user_report1 = UserReport.create!(user_id: @user3.id, report_id: @report4.id)
    @user_report1 = UserReport.create!(user_id: @user4.id, report_id: @report1.id)
    @user_report1 = UserReport.create!(user_id: @user4.id, report_id: @report2.id)
    @user_report1 = UserReport.create!(user_id: @user4.id, report_id: @report5.id)
  end

  describe "#show - user info and list of associated reports" do
    context "happy paths" do
      # it "correctly returns user info for valid ID" do
      it "very basic test" do
        specified_user_id = @user1.id
        get api_v1_user_path(specified_user_id)
        user_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to be_successful
        expect(user_data).to eq({ user_id: @user1.id, message: "well howdy there" })
      end
    end

    context "sad paths" do

    end
  end

  #index

  #update?

  #destroy?

end
