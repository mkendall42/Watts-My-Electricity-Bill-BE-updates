require "rails_helper"

RSpec.describe "EnergyInfo object (non-model)" do
  describe "initialization and loading data" do
    context "happy paths" do
      #Correctly initializes with baseline search data
      it "exists, initializes correctly with baseline data" do
        search_data = {
          #Move to before(:each) if used again?
          nickname: "van down by the river",
          residence_type: "apartment",         #Not really, but need valid data
          num_residents: 2,
          efficiency_level: 1,
          zipcode: 80236
        }

        energy_info = EnergyInfo.new(search_data)

        expect(energy_info).to be_a(EnergyInfo)
        expect(energy_info.residence_name).to eq("van down by the river")
        expect(energy_info.residence_type).to eq("apartment")
        expect(energy_info.num_residents).to eq(2)
        expect(energy_info.efficiency_index).to eq(1)
        expect(energy_info.zip_code).to eq(80236)

      end

      #Check analyze_energy_and_cost() method (once external APIs exist and data can be stubbed)

    end

    context "sad paths" do
      #Returns null or raises error if API call / CSV results invalid (or should this only be handled in gateways/facades/CSV parser?)

      #Maybe: return null or raise error if calculation problem (might not need this, can't think of when this would happen if all data comes back correctly...)

    end
  end

  describe "energy consumption and cost calculations" do
    it "successfully computes two residences, generates reasonable answers" do
      #Basic apartment first
      apartment_data = {
        nickname: "quiet efficient apartment",
        zipcode: 12345,
        residence_type: "apartment",
        num_residents: 1,
        efficiency_level: 2
      }
      efficient_apartment = EnergyInfo.new(apartment_data)
      efficient_apartment.zip_res_rate = 0.12

      efficient_apartment.calculate_energy_consumption
      efficient_apartment.calculate_cost

      expect(efficient_apartment.energy_consumption).to be_a(Float)
      expect(efficient_apartment.energy_consumption.round(1)).to eq(1853.7)
      expect(efficient_apartment.cost).to be_a(Float)
      expect(efficient_apartment.cost.round(1)).to eq(311.4)

      #Now a busy house
      house_data = {
        nickname: "busy electricity guzzling house",
        zipcode: 12345,
        residence_type: "house",
        num_residents: 5,
        efficiency_level: 9
      }
      busy_house = EnergyInfo.new(house_data)
      busy_house.zip_res_rate = 0.12

      busy_house.calculate_energy_consumption
      busy_house.calculate_cost

      expect(busy_house.energy_consumption).to be_a(Float)
      expect(busy_house.energy_consumption.round(1)).to eq(20405.6)
      expect(busy_house.cost).to be_a(Float)
      expect(busy_house.cost.round(1)).to eq(3428.1)
    end
  end

  describe "analyze_energy_and_cost" do
    it "returns a calculated and sanitized residence_data file" do
      CsvHelper.utilityCSV("./db/data/iou_zipcodes_2023.csv")
      
      apartment_data = {
        nickname: "quiet apartment",
        zipcode: 80401,
        residence_type: "apartment",
        num_residents: 1,
        efficiency_level: 1
      }

      analysis = EnergyInfo.analyze_energy_and_cost(apartment_data)

      #Check sample fields to ensure populated correctly
      expect(analysis.state_ind_average).to be_a(Hash)
      expect(analysis.state_ind_average[:sectorName]).to eq("industrial")
      expect(analysis.zip_code).to eq(80401)
      expect(analysis.zip_comm_rate).to be_a(Float)
      expect(analysis.energy_consumption).to be_a(Float)
      expect(analysis.cost).to be_a(Float) 
    end
  end

end
