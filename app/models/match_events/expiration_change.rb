###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module MatchEvents
  class ExpirationChange < Base
    validates :note, presence: true

    def name
      note
    end

  end
end
