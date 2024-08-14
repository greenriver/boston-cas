###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Thirteen
  class Base < ::MatchDecisions::Base
    def accessible_by?(contact)
      contact.user_can_act_on_behalf_of_match_contacts? ||
        contact.in?(match.send(contact_actor_type))
    end
  end
end
