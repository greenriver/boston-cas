###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class FundingSourceService < ApplicationRecord
  belongs_to :funding_source, inverse_of: :funding_source_services
  belongs_to :service, inverse_of: :funding_source_services
end
