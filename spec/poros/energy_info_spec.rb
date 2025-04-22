require "rails_helper"
# require "../poro_path"

RSpec.describe "EnergyInfo object (non-model)" do
  before(:each) do
    #Create a few users
    # @user1 = User.create!(username: "jbickler")
    # @user2 = User.create!(username: "jbloom")
    # @user3 = User.create!(username: "mkendall")
    # @user4 = User.create!(username: "plittle")
    # @user5 = User.create!(username: "jason")
    # #Create a few reports (these will clearly need more info - DB migration - later)
    # @report1 = Report.create!(nickname: "van down by the river", energy_usage: 1219, energy_cost: 461)
    # @report2 = Report.create!(nickname: "small apartment", energy_usage: 1800, energy_cost: 850)
    # @report3 = Report.create!(nickname: "townhouse", energy_usage: 2550, energy_cost: 1284)
    # @report4 = Report.create!(nickname: "5 floor narrow condo", energy_usage: 2663, energy_cost: 1699)
    # @report5 = Report.create!(nickname: "4 bedroom house", energy_usage: 3903, energy_cost: 2497)
    # @report6 = Report.create!(nickname: "vail mountain mansion", energy_usage: 7128, energy_cost: 5088)
    # #Associate 'em:
    # @user_report1 = UserReport.create!(user_id: @user1.id, report_id: @report3.id)
    # @user_report1 = UserReport.create!(user_id: @user1.id, report_id: @report5.id)
    # @user_report1 = UserReport.create!(user_id: @user2.id, report_id: @report6.id)
    # @user_report1 = UserReport.create!(user_id: @user3.id, report_id: @report1.id)
    # @user_report1 = UserReport.create!(user_id: @user3.id, report_id: @report4.id)
    # @user_report1 = UserReport.create!(user_id: @user4.id, report_id: @report1.id)
    # @user_report1 = UserReport.create!(user_id: @user4.id, report_id: @report2.id)
    # @user_report1 = UserReport.create!(user_id: @user4.id, report_id: @report5.id)
  end

  describe "initialization and loading data" do
    context "happy paths" do
      #Correctly initializes with baseline search data
      it "exists, initializes correctly with baseline data" do
        search_data = {
          #Move to before(:each)?
          nickname: "van down by the river",
          residence_type: "apartment",         #Not really, but need valid data
          num_residents: 2,
          efficiency_level: 1,
          latitude: 41.9,
          longitude: -91.5
        }

        energy_info = EnergyInfo.new(search_data)

        expect(energy_info).to be_a(EnergyInfo)
        expect(energy_info.residence_name).to eq("van down by the river")
        expect(energy_info.residence_type).to eq("apartment")
        expect(energy_info.num_residents).to eq(2)
        expect(energy_info.efficiency_index).to eq(1)
        expect(energy_info.coordinates[:latitude]).to eq(41.9)
        expect(energy_info.coordinates[:longitude]).to eq(-91.5)
      end

    end

    context "sad paths" do
      #Returns null or raises error if invalid incoming search data


      #Returns null or raises error if missing incoming search data
      it "returns error for missing incoming search data" do
        
      end
    end
  end

end
