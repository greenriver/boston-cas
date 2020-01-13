###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class FundingSourceService < ApplicationRecord
  belongs_to :funding_source, inverse_of: :funding_source_services
  belongs_to :service, inverse_of: :funding_source_services
end
