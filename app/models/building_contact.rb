class BuildingContact < ActiveRecord::Base

  belongs_to :building, required: true, inverse_of: :building_contacts
  belongs_to :contact, required: true, inverse_of: :building_contacts

  include ContactJoinModel

  acts_as_paranoid

end
