###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module MatchEvents
  class Note < Base
    # Overall Match Notes are implemented as events
    validates :note, presence: true
    attr_accessor :contact_ids
    attr_accessor :include_content

    def name
      if admin_note
        'Administrative note added'
      else
        'Note added'
      end
    end

    def remove_note!
      destroy
    end

    def is_editable?
      true
    end

    def show_note?(current_contact)
      note.present? && (! admin_note || match.can_create_administrative_note?(current_contact))
    end

    def include_in_tracking_sheet?
      true
    end

    def tracking_events
      [[date, "Note: #{note}"]]
    end
  end
end