class SubgranteeContact < ActiveRecord::Base

  belongs_to :subgrantee, required: true, inverse_of: :subgrantee_contacts
  belongs_to :contact, required: true, inverse_of: :subgrantee_contacts

  include ContactJoinModel

  acts_as_paranoid
  has_paper_trail

end
