module Notifications
  class ConfirmMatchSuccessDndStaff < Base
    def self.create_for_match!(match)
      match.dnd_staff_contacts.each do |contact|
        create! match: match, recipient: contact
      end
    end

    def decision
      match.confirm_match_success_dnd_staff_decision
    end

    def event_label
      "#{_('DND')} Staff notified of client housed date and asked to give final confirmation to match."
    end
  end
end
