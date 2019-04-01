module Notifications
  class ScheduleCriminalHearingHousingSubsidyAdmin < Base
    def self.create_for_match!(match)
      match.housing_subsidy_admin_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.schedule_criminal_hearing_housing_subsidy_admin_decision
    end

    def event_label
      "#{_('Housing Subsidy Administrator')} #{_('was sent full details of match for review and scheduling of any necessary criminal background hearings')}"
    end

    def allows_registration?
      true
    end

    def registration_role
      :housing_subsidy_admin
    end
  end
end
