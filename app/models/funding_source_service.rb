###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class FundingSourceService < ActiveRecord::Base
  belongs_to :funding_source, required: :true, inverse_of: :funding_source_services
  belongs_to :service, required: :true, inverse_of: :funding_source_services
end
