###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Five
  class MatchRecommendation < Notifications::Base
    def self.create_for_match! match
      match.housing_subsidy_admin_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.five_match_recommentation_decision
    end

    def event_label
      "#{_('Route Five HSA')} notified of new match"
    end

    def contacts_editable?
      true
    end
  end
end
