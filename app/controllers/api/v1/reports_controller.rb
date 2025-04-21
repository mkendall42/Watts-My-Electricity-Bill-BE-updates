class Api::V1::ReportsController < ApplicationController

  def index
    user = User.find(params[:user_id])
    reports = user.reports
    render json: reports
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end

  def show
    report = Report.find(params[:id])
    render json: report
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Report not found" }, status: :not_found
  end

  def create
    report = Report.new(report_params.except(:user_id))
    
    if report.save
      UserReport.create!(user_id: report_params[:user_id], report_id: report.id)
      render json: report, status: :created
    end
  end

  def energy_usage
    usage_data = {
      location: params[:location],
      type: params[:type],
      occupants: params[:occupants],
      energy_usage: params[:energy_usage]
    }

    render json: usage_data
  end

  private

  def report_params
    params.permit(:user_id, :nickname, :energy_usage, :energy_cost)
  end
end