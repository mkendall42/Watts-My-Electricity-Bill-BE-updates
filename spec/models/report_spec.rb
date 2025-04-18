require "rails_helper"

RSpec.describe Report, type: :model do
  describe "relationships" do
    it { should have_one(:user).through(:user_report) }
  end

end
