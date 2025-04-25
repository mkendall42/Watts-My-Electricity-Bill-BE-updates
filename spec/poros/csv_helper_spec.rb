require "rails_helper"

RSpec.describe "CsvHelper" do
  before(:each) do
    @data = CsvHelper.utilityCSV("./db/data/iou_zipcodes_2023.csv")
  end
  describe "initialization and loading data" do
    it "converts CSV to Ruby objects in factory" do
      expect(@data[0].state).to eq("AZ")
      expect(@data[0].zipcode).to eq(85321)
      expect(@data[1].state).to eq("AL")
    end
  end

  describe "price_by_zip" do
    it "selects the different price rates from a specified zip code" do
      expect(CsvHelper.price_by_zip(80401)).to eq(
        {
      residential: 0.14335370009863208,
      industrial: 0.08032814635818483,
      commercial: 0.11750181035317799
    }
      )
    end
  end

  describe "state_by_zip" do
    it "selects the state associated with the entered zipcode" do
      expect(CsvHelper.state_by_zip(80401)).to eq("CO")
      expect(CsvHelper.state_by_zip(14813)).to eq("NY")
    end
  end

  describe "price_by_state" do
    it "returns the average cost per state" do
      average = CsvHelper.price_by_state("CO")
      expect(average).to eq(0.14868510749724945)
    end
  end
end