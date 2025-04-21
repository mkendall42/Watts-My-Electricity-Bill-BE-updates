class Api::V1::UsersController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :invalid_id

  #Additional likely actions:
  # - index (list all users, for FE dropdown)
  # - create (new user, probably pretty simple)
  # - update (add report to existing user...other things too?)
  # - destroy (optional, if we want to have this at all)

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

