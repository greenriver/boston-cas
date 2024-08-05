###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Notifications::Eleven
  class HsaAcceptsClient < ::Notifications::Base
    def self.create_for_match! match
      match.housing_subsidy_admin_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def notification_type
      # prefix used for finding relevant information in other objects
      # e.g. mailer, match decisions
      "eleven_#{self.class.to_s.demodulize.underscore}"
    end

    def event_label
      "#{Translation.translate('Housing Subsidy Administrator Eleven')} reviews match with client"
    end

    def show_client_info?
      true
    end

    def allows_registration?
      true
    end

    def registration_role
      :housing_subsidy_admin
    end

    def contacts_editable?
      true
    end
  end
end
