###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

module MatchDecisionReasons
  class AdministrativeCancel < Base
    def title
      Translation.translate('Administrative Cancelation')
    end
  end
end
