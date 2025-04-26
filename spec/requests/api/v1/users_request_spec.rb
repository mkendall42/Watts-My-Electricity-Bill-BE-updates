require "rails_helper"

RSpec.describe "Users controller", type: :request do
  before(:each) do
    #Create a few users
    @user1 = User.create!(username: "jbickler", id: 1)
    @user2 = User.create!(username: "jbloom", id: 2)
    @user3 = User.create!(username: "mkendall", id: 3)
    @user4 = User.create!(username: "plittle", id: 4)
    @user5 = User.create!(username: "jason", id: 5)
    #Create a few reports (these will clearly need more info - DB migration - later)
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

    @report4 = Report.create!(
      nickname: "it's a huge house",
      energy_consumption: 300,
      energy_cost: 39.99,
      state: "SE",
      state_residential_avg: 12,
      state_industrial_avg: 22,
      state_commercial_avg: 12,
      zip_residential_avg: 0.01,
      zip_industrial_avg: 0.02,
      zip_commercial_avg: 0.02,
    )

    @report5 = Report.create!(
      nickname: "4 bedroom house",
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

    @report6 = Report.create!(
      nickname: "tiny place",
      energy_consumption: 50,
      energy_cost: 39.99,
      state: "CA",
      state_residential_avg: 12,
      state_industrial_avg: 22,
      state_commercial_avg: 12,
      zip_residential_avg: 0.01,
      zip_industrial_avg: 0.02,
      zip_commercial_avg: 0.02,
    )
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
      it "correctly returns user info for valid ID" do
        specified_user = @user1
        get api_v1_user_path(specified_user.id)
        user_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to be_successful
        expect(user_data).to have_key(:username)
        expect(user_data[:username]).to eq(specified_user.username)
        expect(user_data).to have_key(:num_reports)
        expect(user_data[:num_reports]).to eq(2)
        expect(user_data).to have_key(:reports)
        expect(user_data[:reports]).to be_a(Array)
        expect(user_data[:reports].length).to eq(2)
        user_data[:reports].each do |report|
          expect(report).to have_key(:nickname)
          expect(report).to have_key(:id)
        end
        expect(user_data[:reports][0][:nickname]).to eq("Bob’s Bill")
        expect(user_data[:reports][0][:id]).to eq(@report3.id)
        expect(user_data[:reports][1][:nickname]).to eq("4 bedroom house")
        expect(user_data[:reports][1][:id]).to eq(@report5.id)
      end

      it "correctly returns empty array for user with no reports" do
        specified_user = @user5
        get api_v1_user_path(specified_user.id)
        user_data = JSON.parse(response.body, symbolize_names: true)

        expect(response).to be_successful
        expect(user_data[:username]).to eq(specified_user.username)
        expect(user_data[:num_reports]).to eq(0)
        expect(user_data[:reports]).to eq([])
      end
    end

    context "sad paths" do
      it "invalid ID yields appropriate error" do
        invalid_id = 10000
        get api_v1_user_path(invalid_id)
        error_message = JSON.parse(response.body, symbolize_names: true)

        expect(response).to_not be_successful
        expect(error_message[:status]).to eq(404)
        expect(error_message[:message]).to eq("Error: Couldn't find User with 'id'=#{invalid_id}.")
      end
      it "returns a user based on ID" do
        get "/api/v1/users/1"

        expect(response).to be_successful
        json = JSON.parse(response.body, symbolize_names: true)

        expect(json.count).to eq(3)
        expect(json[:username]). to eq("jbickler")

        get "/api/v1/users/2"

        expect(response).to be_successful
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:username]). to eq("jbloom")
      end
    end
  end

  #index
  describe "#index" do
    it "returns all users" do
      get "/api/v1/users"

      expect(response).to be_successful
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json.count).to eq(5)
      expect(json[0][:username]). to eq("jbickler")
    end
  end
end
