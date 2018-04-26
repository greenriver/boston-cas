class DeidentifiedClient < ActiveRecord::Base
  validates :client_identifier, uniqueness: true
  
  has_paper_trail
  acts_as_paranoid
end
