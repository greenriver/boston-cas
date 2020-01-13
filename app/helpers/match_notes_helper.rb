###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module MatchNotesHelper

  def match_note_referrer_params
    params.slice :referring_notification_code
  end

end