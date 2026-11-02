###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module MatchDecisions::Fourteen
  class Base < ::MatchDecisions::Base
    def accessible_by?(contact)
      contact&.user_can_act_on_behalf_of_match_contacts? ||
        contact&.in?(match.send(contact_actor_type))
    end

    def label
      label_for_status status
    end
  end
end
