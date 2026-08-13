###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class MatchMitigationReason < ApplicationRecord
  belongs_to :client_opportunity_match
  belongs_to :mitigation_reason

  delegate :name, to: :mitigation_reason

  scope :addressed, -> do
    where(addressed: true)
  end
end
