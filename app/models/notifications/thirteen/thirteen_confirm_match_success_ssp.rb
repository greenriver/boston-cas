###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Notifications::Thirteen
  class ThirteenConfirmMatchSuccessSsp < ::Notifications::Base
    def self.create_for_match! match
      match.ssp_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.thirteen_hsa_review_decision
    end

    def event_label
      "#{Translation.translate('HSA Thirteen')} notified of referral acceptance."
    end
  end
end
