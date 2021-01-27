###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class SubgranteeContact < ApplicationRecord

  belongs_to :subgrantee, inverse_of: :subgrantee_contacts
  belongs_to :contact, inverse_of: :subgrantee_contacts

  include ContactJoinModel

  acts_as_paranoid
  has_paper_trail

end
