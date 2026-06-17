###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class SubgranteeContact < ApplicationRecord

  belongs_to :subgrantee, inverse_of: :subgrantee_contacts
  belongs_to :contact, inverse_of: :subgrantee_contacts

  include ContactJoinModel

  acts_as_paranoid
  has_paper_trail

end
