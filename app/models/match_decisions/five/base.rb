###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module MatchDecisions::Five
  class Base < ::MatchDecisions::Base
    def actor_type
      MatchRoutes::Five.new.contact_label_for(contact_actor_type)
    end
  end
end
