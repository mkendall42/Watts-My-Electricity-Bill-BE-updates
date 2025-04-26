require "rails_helper"

RSpec.describe "Utilities controller", type: :request do
  describe "#show - FE requests utility data rates from BE for specific search criteria" do
    #NOTE: add zip code checking (and make sure lat/lon removed)
    #NOTE: update uniqueness checking if needed
    context "happy paths" do
      #One example (simple) - basic mocked/stubbed external API call to one location
      it "basic successful test" do
        get "#{api_v1_utilities_path}?nickname=apt&zipcode=80236&residence_type=apartment&num_residents=2&efficiency_level=1"
        utility_info = JSON.parse(response.body, symbolize_names: true)

        expect(response).to be_successful
        expect(utility_info).to have_key(:nickname)
        expect(utility_info).to have_key(:energy_consumption)
        # expect(utility_info).to have_key(:cost)
        expect(utility_info[:nickname]).to eq("apt")
        expect(utility_info[:energy_consumption]).to eq(3789.291416275995)
        expect(utility_info[:cost]).to eq(760.4925233852096)

      end

      #Another example (simple) - basic mocked/stubbed external API call to second location

      #Another example (full) - actual API call to a location (can we toggle this to only sometimes run?)
    end

    context "sad paths" do 
      describe "query parameter issues" do
        it "emtpy `request (all query params missing)" do
          get api_v1_utilities_path
          response_message = JSON.parse(response.body, symbolize_names: true)

          expect(response).to_not be_successful
          expect(response_message[:status]).to eq(422)
          expect(response_message[:message].length).to eq(5)
          # expect(response_message[:message][2]).to eq("Error: required parameter 'longitude' is missing.")
        end
        
        it "one param missing" do
          get "#{api_v1_utilities_path}?nickname=apt&zipcode=80236&num_residents=2&efficiency_level=1"
          response_message = JSON.parse(response.body, symbolize_names: true)

          expect(response).to_not be_successful
          expect(response_message[:status]).to eq(422)
          expect(response_message[:message]).to eq(["Error: required parameter 'residence_type' is missing."])
        end
        
        it "all parameters are invalid / out of range" do
          #Since error messages are generated separately, this covers all bases in essence
          Report.create!(
            nickname: "newplace",
            energy_consumption: 234,
            energy_cost: 74.39,
            state: "CO",
            state_residential_avg: 12,
            state_industrial_avg: 22,
            state_commercial_avg: 12,
            zip_residential_avg: 0.01,
            zip_industrial_avg: 0.02,
            zip_commercial_avg: 0.02,
          )

          get "#{api_v1_utilities_path}?nickname=newplace&zipcode=80236&residence_type=shack&num_residents=-1&efficiency_level=4"
          response_message = JSON.parse(response.body, symbolize_names: true)

          expect(response).to_not be_successful
          expect(response_message[:message].length).to eq(3)
          # expect(response_message[:message][0]).to eq("Error: nickname must be unique.")
          # expect(response_message[:message][1]).to eq("Error: latitude/longitude values must be legal.")
          expect(response_message[:message][0]).to eq("Error: residence type must be 'apartment' or 'house'.")
          expect(response_message[:message][1]).to eq("Error: number of residents must be an integer > 0.")
          expect(response_message[:message][2]).to eq("Error: efficiency level must be 1 or 2.")
        end

      end

      #Unable to connect to external APIs / get data (404 response or similar)
      
      #Maybe: external API and/or PORO / other BE processing yields strange data

    end
  end

end
