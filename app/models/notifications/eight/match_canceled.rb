# frozen_string_literal: true

###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Eight
  class MatchCanceled < Notifications::MatchCanceled
    # Send to all contacts
    def self.contact_types_for_notification
      [:contacts]
    end

    def self.create_for_match!(match, decision_id: nil)
      Notifications::Base.instance_method(:create_for_match!).bind(self).call(match, decision_id: decision_id)
    end
  end
end
