class UtilitiesController < ApplicationController
  #For now, #index makes the most sense, since it would not be easy to know a utility ID in advance (i.e. for #show)
  #Later index might be useful for other queries (browse multiple possible utilities, etc.), or maybe even use #show, or #create for common searches, etc.

  def index
    #Check request and params from FE, verify presence and validity

    #Hand off to gateway / Farady to make external API call(s)

    #Once external API has responded, parse raw data and massage / store into object (PORO likely?)
    #NOTE: ensure this 'waits' properly until external API has responded, etc.

    #Process anything necessary / calculations, then serialize and return JSON to FE.

  end
end
