###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module Notifications::HomelessSetAside
  class HsaAcceptsClientSspNotification < ::Notifications::Base

    def self.create_for_match! match
      match.ssp_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def event_label
      "#{_'SSP'} notified of #{_('Housing Subsidy Administrator')} acceptance"
    end

    def show_client_info?
      true
    end

    def allows_registration?
      false
    end

  end
end
