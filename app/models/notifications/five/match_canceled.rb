###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Five
  class MatchCanceled < Notifications::MatchCanceled
    # Send to all contacts
    def self.contact_types_for_notification
      [:contacts]
    end

    def self.create_for_match!(match, decision_id: nil)
      Notifications::Base.singleton_class.instance_method(:create_for_match!).bind(self).call(match, decision_id: decision_id)
    end
  end
end
