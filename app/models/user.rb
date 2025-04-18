class User < ApplicationRecord
  # Establish a many-to-one relationship with Report(s) - can later be updated to many-to-many (DB should already be set up to do this)
  #Later - might wish to delete reports associated with a user like dependent: :destroy (though we would not want that if we implement sample reports / locations)
  has_many :user_reports
  has_many :reports, through: :user_reports
end