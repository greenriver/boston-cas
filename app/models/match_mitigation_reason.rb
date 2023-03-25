###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class MatchMitigationReason < ApplicationRecord
  belongs_to :client_opportunity_match
  belongs_to :mitigation_reason

  delegate :name, to: :mitigation_reason

  scope :addressed, -> do
    where(addressed: true)
  end
end
