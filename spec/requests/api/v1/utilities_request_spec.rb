require "rails_helper"

RSpec.describe "Utilities controller", type: :request do
  describe "#show - FE requests utility data rates from BE for specific search criteria" do
    context "happy paths" do
      it "very basic initial test" do
        #Very basic initial test(s)
        get api_v1_utilities_path
        # get "/api/v1/utilities"
        response_message = JSON.parse(response.body, symbolize_names: true)

        expect(response).to_not be_successful
        # expect(response_message).to eq({ message: "Error" })
        expect(response_message[:status]).to eq(400)
        expect(response_message[:message].length).to eq(7)
        expect(response_message[:message][2]).to eq("Error: required parameter 'longitude' is missing.")

      end

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