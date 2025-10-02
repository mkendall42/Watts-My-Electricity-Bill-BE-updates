require 'rails_helper'

RSpec.describe "Api::V1::ReportsController", type: :request do
  before(:each) do
    @user = User.create!(username: "test_user")
  end

  describe "GET /api/v1/users/:user_id/reports" do
    it "returns all reports for a user" do
      report = Report.create!(
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
      UserReport.create!(user: @user, report: report)

      get "/api/v1/users/#{@user.id}/reports"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body.first[:nickname]).to eq("House")
      expect(body.first[:energy_consumption]).to eq(234)
      expect(body.first[:energy_cost]).to eq(74.39)
      expect(body.first[:state]).to eq("CO")
      expect(body.first[:state_residential_avg]).to eq(12)
      expect(body.first[:state_industrial_avg]).to eq(22)
      expect(body.first[:state_commercial_avg]).to eq(12)
      expect(body.first[:zip_residential_avg]).to eq(0.01)
      expect(body.first[:zip_industrial_avg]).to eq(0.02)
      expect(body.first[:zip_commercial_avg]).to eq(0.02)
    end

    it "returns 404 if user is not found" do
      get "/api/v1/users/999/reports"

      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to include("Couldn't find User")
    end
  end

  describe "GET /api/v1/reports/:id" do
    it "returns a specific report" do
      report = Report.create!(nickname: "Cabin", energy_consumption: 300, energy_cost: 120.0)

      get "/api/v1/reports/#{report.id}"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["nickname"]).to eq("Cabin")
    end

    it "returns 404 if report is not found" do
      get "/api/v1/reports/9999"

      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to include("Couldn't find Report")
    end
  end

  describe "POST /api/v1/reports" do
    it "creates a new report and links it to a user" do
      post "/api/v1/reports", params: {
        user_id: @user.id,
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
      }

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body[:nickname]).to eq("House")
      expect(body[:energy_consumption]).to eq(234)
      expect(body[:energy_cost]).to eq(74.39)
      expect(body[:state]).to eq("CO")
      expect(body[:state_residential_avg]).to eq(12)
      expect(body[:state_industrial_avg]).to eq(22)
      expect(body[:state_commercial_avg]).to eq(12)
      expect(body[:zip_residential_avg]).to eq(0.01)
      expect(body[:zip_industrial_avg]).to eq(0.02)
      expect(body[:zip_commercial_avg]).to eq(0.02)
    end

    it "returns 422 if required params are missing" do
      post "/api/v1/reports", params: {
        user_id: @user.id,
        energy_consumption: nil
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 422 if requested nickname is not unique" do
      #Need existing report(s) to challenge uniqueness
      report = Report.create!(nickname: "Cabin", energy_consumption: 300, energy_cost: 120.0)
      user_report1 = UserReport.create!(user_id: @user.id, report_id: report.id)


      post "/api/v1/reports", params: {
        user_id: @user.id,
        nickname: "Cabin",
        energy_consumption: 150,
        energy_cost: 80,
        state: "WY",
        state_residential_avg: 0.11,
        state_commercial_avg: 0.11,
        state_industrial_avg: 0.11,
        zip_residential_avg: 0.12,
        zip_commercial_avg: 0.12,
        zip_industrial_avg: 0.12
      }
      error_message = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(error_message[:status]).to eq(422)
      expect(error_message[:message]).to eq("Nickname must be unique.")
      expect(Report.count).to eq(1)
    end
  end

  #I'm not sure what this is...there is no endpoint for this...
  # describe "GET /api/v1/reports/energy_consumption" do
  #   it "returns simulated energy usage data" do
  #     # get "/api/v1/reports/energy_consumption", params: {
  #     get "/api/v1/reports/energy_consumption", params: {
  #       location: "NY",
  #       type: "apartment",
  #       occupants: 2,
  #       energy_consumption: 400
  #     }

  #     expect(response).to have_http_status(:ok)
  #     body = JSON.parse(response.body)
  #     expect(body["location"]).to eq("NY")
  #     expect(body["type"]).to eq("apartment")
  #     expect(body["occupants"]).to eq("2") 
  #   end
  # end

  describe "DELETE /api/v1/reports/:id" do
    it "deletes a specified record correctly" do
      report_1 = Report.create!(nickname: "Van down by the river", energy_consumption: 200, energy_cost: 120.0)
      tmp_id_1 = report_1.id
      report_2 = Report.create!(nickname: "Motorhome by the lake", energy_consumption: 350, energy_cost: 240.0)
      tmp_id_2 = report_2.id
      report_3 = Report.create!(nickname: "Modular house by the ocean", energy_consumption: 500, energy_cost: 360.0)

      UserReport.create!(user: @user, report: report_1)
      UserReport.create!(user: @user, report: report_2)

      delete api_v1_report_path(tmp_id_1)
      body = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(body[:deleted_report][:nickname]).to eq("Van down by the river")
      expect(body[:deleted_report][:id]).to eq(tmp_id_1)
      expect(body[:deleted_report][:associated_username]).to eq("test_user")
      expect(body[:num_remaining_reports]).to eq(2)
      
      expect(Report.all.length).to eq(2)
      expect{ Report.find(tmp_id_1) }.to raise_error(ActiveRecord::RecordNotFound)

      delete api_v1_report_path(tmp_id_2)
      body = JSON.parse(response.body, symbolize_names: true)

      expect(Report.all.length).to eq(1)
      expect{ Report.find(tmp_id_2) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "returns 404 if specified report does not exist" do
      absurdly_large_id = 10000000
      delete api_v1_report_path(absurdly_large_id)
      error_message = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:not_found)
      expect(error_message).to be_a(Hash)
      expect(error_message[:error]).to eq("Couldn't find Report with 'id'=#{absurdly_large_id}")
    end
  end
end
