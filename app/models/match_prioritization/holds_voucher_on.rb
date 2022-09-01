###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchPrioritization
  class HoldsVoucherOn < Base
    def self.title
      'Date voucher was assigned'
    end

    def self.prioritization_for_clients(scope, match_route:) # rubocop:disable Lint/UnusedMethodArgument
      scope.order(c_t[:holds_voucher_on].asc)
    end

    def self.client_prioritization_summary_method
      'holds_voucher_on'
    end
  end
end
