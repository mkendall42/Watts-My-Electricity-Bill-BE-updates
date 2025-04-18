require "rails_helper"

RSpec.describe UtilitiesController, type: :request do
  describe "#show - FE requests utility data rates from BE for specific search criteria" do
    context "happy paths" do
      #One example (simple) - basic mocked/stubbed external API call to one location

      #Another example (simple) - basic mocked/stubbed external API call to second location

      #Another example (full) - actual API call to a location (can we toggle this to only sometimes run?)
    end

    context "sad paths" do 
      #Not all parameters are present or valid

      #Unable to connect to external APIs
      
      #Maybe: external API and/or PORO / other BE processing yields strange data

    end
  end

end