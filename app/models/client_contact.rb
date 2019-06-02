class ClientContact < ActiveRecord::Base

  belongs_to :client, required: true, inverse_of: :client_contacts
  belongs_to :contact, required: true, inverse_of: :client_contacts

  acts_as_paranoid
  has_paper_trail

end
