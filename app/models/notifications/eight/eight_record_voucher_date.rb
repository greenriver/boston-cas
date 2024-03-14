###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Eight
  class EightRecordVoucherDate < ::Notifications::Base
    def self.create_for_match! match
      match.housing_subsidy_admin_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.eight_record_voucher_date_decision
    end

    def event_label
      "#{Translation.translate('Housing Subsidy Administrator Eight')} notified of approved potential match."
    end
  end
end
