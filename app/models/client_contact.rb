class ClientContact < ActiveRecord::Base
  belongs_to :client, required: true, inverse_of: :client_contacts
  belongs_to :contact, required: true, inverse_of: :client_contacts

  include ContactJoinModel

  acts_as_paranoid
  has_paper_trail

  scope :regular, -> { where regular: true }
  scope :shelter_agency, -> { where shelter_agency: true }
end
