class Api::V1::UsersController < ApplicationController
  #Additional likely actions:
  # - index (list all users, for FE dropdown)
  # - create (new user, probably pretty simple)
  # - update (add report to existing user...other things too?)
  # - destroy (optional, if we want to have this at all)

  def show
    #Return info about user, including saved reports (residences / searches)

    #Look up user by ID
    user = User.find(params[:id])

    #Render information via serializer
    # render json: { user_id: user.id, message: "well howdy there" }
    render json: UsersSerializer.format_single_user(user)
  end
end