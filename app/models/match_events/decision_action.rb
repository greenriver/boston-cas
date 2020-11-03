###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchEvents
  class DecisionAction < Base

    def name
      decision_name = decision.label_for_status self.action
      if not_working_with_client_reason.present?
        decision_name << "; no longer working with client: #{not_working_with_client_reason.name}"
      end
      if client_last_seen_date.present?
        decision_name << "; last seen: #{client_last_seen_date}"
      end
      decision_name
    end

    def show_note?(current_contact)
      note.present? && (! admin_note || match.can_create_administrative_note?(current_contact))
    end

    def include_in_tracking_sheet?
      true
    end

    def tracking_events
      events = []
      events << [date, "Note: #{note}"] if note.present?
      case action
      when 'back'
        events << [date, 'Step rewound']
      when 'accepted'
        events << [date, 'Step completed']
      end
      events
    end

    def next_step_number(step_number)
      case action
      when 'back'
        step_number - 1
      when 'accepted'
        step_number + 1
      else
        step_number
      end
    end
  end
end