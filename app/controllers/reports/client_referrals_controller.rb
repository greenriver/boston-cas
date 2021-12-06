###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###
module Reports
  class ClientReferralsController < ApplicationController
    before_action :authenticate_user!

    # TODO
    # add this as a report
    # Export selected clients
    # Optionally add Referral Event
    def index
    end
  end
end
