###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class SubgranteeService < ActiveRecord::Base
  belongs_to :subgrantee, required: :true, inverse_of: :subgrantee_services
  belongs_to :service, required: :true, inverse_of: :subgrantee_services
end
