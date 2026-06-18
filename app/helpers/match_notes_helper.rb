###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module MatchNotesHelper

  def match_note_referrer_params
    params.slice :referring_notification_code
  end

end
