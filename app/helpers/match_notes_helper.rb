###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchNotesHelper

  def match_note_referrer_params
    params.slice :referring_notification_code
  end

end
