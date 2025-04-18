class Api::V1::UtilitiesController < ApplicationController
  #For now, #index makes the most sense, since it would not be easy to know a utility ID in advance (i.e. for #show)
  #Later index might be useful for other queries (browse multiple possible utilities, etc.), or maybe even use #show, or #create for common searches, etc.

  def index
    #Check request and params from FE, verify presence and validity
    if !validate_params(params)
      render json: { message: "Error" }, status: 400
      # return
    else
      #Hand off to gateway / Farady to make external API call(s)
      #NOTE: will be implemented in later ticket
  
      #Once external API has responded, parse raw data and massage / store into object (PORO likely?)
      #NOTE: ensure this 'waits' properly until external API has responded, etc.
      #NOTE: for starters, just mock returned basic data (even skipping PORO) to render
  
      #Process anything necessary / calculations, then serialize and return JSON to FE.
      render json: { message: "Success" }
    end
  end

  private

  def validate_params(params)
    #This will have more details later.  Plan is to return a hash with any errors (or empty hash if successful)
    #Later later: might have it raise exceptions one by one

    return false
  end
end
