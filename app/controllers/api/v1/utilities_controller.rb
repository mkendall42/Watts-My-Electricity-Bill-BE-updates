class Api::V1::UtilitiesController < ApplicationController
  #For now, #index makes the most sense, since it would not be easy to know a utility ID in advance (i.e. for #show)
  #Later index might be useful for other queries (browse multiple possible utilities, etc.), or maybe even use #show, or #create for common searches, etc.

  def index
    #Check request and params from FE, verify presence and validity
    if (messages = validate_params(params)) != []
      render json: ErrorSerializer.format_params_error(messages, 422), status: :unprocessable_content
    else
      #Hand off to gateway / Farady to make external API call(s) (later ticket)
  
      #Once external API has responded, parse raw data and massage / store into object (PORO likely?)
      #NOTE: for starters, just mock returned basic data to render
      residence_data = EnergyInfo.new(params.permit(:nickname, :latitude, :longitude, :residence_type, :num_residents, :efficiency_level, :username))
  
      #Process anything necessary / calculations, then serialize and return JSON to FE.
      render json: UtilitiesSerializer.format_energy_data(residence_data)
    end
  end

  private

  def validate_params(params)
    #This will have more details later.  Plan is to return a hash with any errors (or empty hash if successful)
    #Later later: might have it raise exceptions one by one

    #Returns empty array if ok (params good), nonempty array if error(s)
    messages = []
    required_params = [:nickname, :latitude, :longitude, :residence_type, :num_residents, :efficiency_level]
    required_params.each do |required_param|
      messages << "Error: required parameter '#{required_param}' is missing." if !params[required_param].present?
    end

    #Also check data ranges are valid (could move to Rails 'validate' if we add this to DB later)
    # check_lat_long(params[:latitude], params[:longitude])
    
    #Check nickname is unique
    # result = Report.is_unique_nickname?(params[:nickname])
    messages2 = []
    messages2 << "Error: nickname must be unique." if !Report.is_unique_nickname?(params[:nickname])
    messages2 << "Error: latitude/longitude values must be legal." if !(params[:latitude].to_i > -90 && params[:latitude].to_i < 90 && params[:longitude].to_i > -180 && params[:longitude].to_i < 180)
    messages2 << "Error: residence type must be 'apartment' or 'house'." if !["apartment", "house"].include?(params[:residence_type])
    messages2 << "Error: number of residents must be an integer > 0." if !(params[:num_residents].to_i > 0)
    messages2 << "Error: efficiency level must be 1 or 2." if ![1, 2].include?(params[:efficiency_level].to_i)
    
    return messages
  end
end
