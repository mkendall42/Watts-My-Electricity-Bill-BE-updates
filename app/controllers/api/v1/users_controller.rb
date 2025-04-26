class Api::V1::UsersController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :invalid_id

  def index
    users = User.all
    render json: UsersSerializer.format_users(users)
  end

  def show
    #Return info about user, including saved reports (residences / searches) with basic (but not complete) info
    user = User.find(params[:id])

    #Render information via serializer
    render json: UsersSerializer.format_single_user(user)
  end

  private

  def invalid_id(exception)
    render json: ErrorSerializer.format_user_error("Error: #{exception.message}.", 404), status: 404
  end
end

