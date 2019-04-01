module MatchNotesHelper
  def match_note_referrer_params
    params.slice :referring_notification_code
  end
end
