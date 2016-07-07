class FundingSourceService < ActiveRecord::Base
  belongs_to :funding_source, required: :true, inverse_of: :funding_source_services
  belongs_to :service, required: :true, inverse_of: :funding_source_services
end
