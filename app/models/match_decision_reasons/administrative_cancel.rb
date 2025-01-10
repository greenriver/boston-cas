###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisionReasons
  class AdministrativeCancel < Base
    def title
      Translation.translate('Administrative Cancelation')
    end
  end
end
