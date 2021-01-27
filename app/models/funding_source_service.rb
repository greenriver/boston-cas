###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class FundingSourceService < ApplicationRecord
  belongs_to :funding_source, inverse_of: :funding_source_services
  belongs_to :service, inverse_of: :funding_source_services
end
