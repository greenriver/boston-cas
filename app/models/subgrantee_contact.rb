###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class SubgranteeContact < ActiveRecord::Base

  belongs_to :subgrantee, required: true, inverse_of: :subgrantee_contacts
  belongs_to :contact, required: true, inverse_of: :subgrantee_contacts

  include ContactJoinModel

  acts_as_paranoid
  has_paper_trail

end
