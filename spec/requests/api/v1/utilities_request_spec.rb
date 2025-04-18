require "rails_helper"

RSpec.describe "Utilities controller", type: :request do
  describe "#show - FE requests utility data rates from BE for specific search criteria" do
    context "happy paths" do
      #One example (simple) - basic mocked/stubbed external API call to one location

      #Another example (simple) - basic mocked/stubbed external API call to second location

      #Another example (full) - actual API call to a location (can we toggle this to only sometimes run?)
    end

    context "sad paths" do 
      describe "query parameter issues" do
        it "emtpy `request (all query params missing)" do
          get api_v1_utilities_path
          response_message = JSON.parse(response.body, symbolize_names: true)

          expect(response).to_not be_successful
          expect(response_message[:status]).to eq(400)
          expect(response_message[:message].length).to eq(6)
          expect(response_message[:message][2]).to eq("Error: required parameter 'longitude' is missing.")
        end
        
        it "one param missing" do
          get "#{api_v1_utilities_path}?nickname=apt&latitude=-19&longitude=-133&num_residents=2&efficiency_level=1"
          response_message = JSON.parse(response.body, symbolize_names: true)

          expect(response).to_not be_successful
          expect(response_message[:status]).to eq(400)
          expect(response_message[:message]).to eq(["Error: required parameter 'residence_type' is missing."])
        end
        
        #Not all parameters are valid

      end

      #Unable to connect to external APIs
      
      #Maybe: external API and/or PORO / other BE processing yields strange data

    end
  end

end