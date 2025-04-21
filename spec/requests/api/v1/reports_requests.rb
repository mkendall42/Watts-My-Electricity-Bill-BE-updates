require 'rails_helper'

RSpec.describe "Api::V1::ReportsController", type: :request do
  before(:each) do
    @user = User.create!(username: "test_user")
  end

  describe "GET /api/v1/users/:user_id/reports" do
    it "returns all reports for a user" do
      report = Report.create!(nickname: "Apartment", energy_usage: 100, energy_cost: 75.0)
      UserReport.create!(user: @user, report: report)

      get "/api/v1/users/#{@user.id}/reports"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.first["nickname"]).to eq("Apartment")
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
      report = Report.create!(nickname: "Cabin", energy_usage: 300, energy_cost: 120.0)

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
        nickname: "Studio",
        energy_usage: 150,
        energy_cost: 80
      }

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["nickname"]).to eq("Studio")
    end

    it "returns 422 if required params are missing" do
      post "/api/v1/reports", params: {
        user_id: @user.id,
        energy_usage: nil
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /api/v1/reports/energy_usage" do
    it "returns simulated energy usage data" do
      get "/api/v1/reports/energy_usage", params: {
        location: "NY",
        type: "apartment",
        occupants: 2,
        energy_usage: 400
      }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["location"]).to eq("NY")
      expect(body["type"]).to eq("apartment")
      expect(body["occupants"]).to eq("2") 
    end
  end
end