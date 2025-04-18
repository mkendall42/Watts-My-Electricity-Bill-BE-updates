require "rails_helper"

RSpec.describe UserReport, type: :model do
  describe "relationships" do
    it { should belong_to(:user) }
    it { should belong_to(:report) }
  end

end
