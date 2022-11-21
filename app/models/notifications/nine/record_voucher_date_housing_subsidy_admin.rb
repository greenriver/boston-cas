###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Nine
  class RecordVoucherDateHousingSubsidyAdmin < ::Notifications::Base
    def self.create_for_match! match
      match.housing_subsidy_admin_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.nine_record_voucher_date_housing_subsidy_admin_decision
    end

    def event_label
      "#{_('Housing Subsidy Administrator Nine')} notified of approved potential match."
    end
  end
end
