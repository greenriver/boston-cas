###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Six
  class ShelterAgencyAccepted < ::Notifications::ShelterAgencyAccepted
    def notification_type
      # prefix used for finding relevant information in other objects
      # e.g. mailer, match decisions
      "six_#{self.class.to_s.demodulize.underscore}"
    end

    def decision
      match.six_approve_match_housing_subsidy_admin_decision
    end
  end
end
