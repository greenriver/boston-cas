###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Five
  class Base < ::MatchDecisions::Base
    def actor_type
      MatchRoutes::Five.new.contact_label_for(contact_actor_type)
    end
  end
  end