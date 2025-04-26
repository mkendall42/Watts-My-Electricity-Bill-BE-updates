require 'csv'
class Api::V1::UtilitiesController < ApplicationController
  #For now, #index makes the most sense, since it would not be easy to know a utility ID in advance (i.e. for #show)
  #Later index might be useful for other queries (browse multiple possible utilities, etc.), or maybe even use #show, or #create for common searches, etc.

  def index
    #Check request and params from FE, verify presence and validity
    if (messages = validate_params(params)) != []
      render json: ErrorSerializer.format_params_error(messages, 422), status: :unprocessable_content
    else
      #Generate energy information based on API calls via gateways, sanitizing data, and running calculations:
      # CsvHelper.utilityCSV("./db/data/iou_zipcodes_2023.csv")
      residence_data = EnergyInfo.analyze_energy_and_cost(params.permit(:nickname, :zipcode, :residence_type, :num_residents, :efficiency_level))
      p residence_data 
      #Process anything necessary / calculations, then serialize and return JSON to FE.
      render json: UtilitiesSerializer.format_energy_data(residence_data)
    end
  end

  private

  def validate_params(params)
    #This is in the controller since it makes sense to validate params BEFORE creating an EnergyInfo object and running API calls
    #Returns empty array if ok (params good), nonempty array if error(s)
    messages = []
    required_params = [:nickname, :zipcode, :residence_type, :num_residents, :efficiency_level]
    required_params.each do |required_param|
      messages << "Error: required parameter '#{required_param}' is missing." if !params[required_param].present?
    end

    return messages if messages != []

    #Validate incoming parameters appropriately
    # messages << "Error: nickname must be unique." if !Report.is_unique_nickname?(params[:nickname])
    # messages << "Error: zipcode value must be legal." if param[:zipcode].length != 5
    messages << "Error: residence type must be 'apartment' or 'house'." if !["apartment", "house"].include?(params[:residence_type])
    messages << "Error: number of residents must be an integer > 0." if !(params[:num_residents].to_i > 0)
    messages << "Error: efficiency level must be within the range 1-10." if ((1..10).to_a.include?(params[:efficiency_level].to_i))
    
    return messages
  end
end
