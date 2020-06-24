###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class SubgranteeService < ApplicationRecord
  belongs_to :subgrantee, inverse_of: :subgrantee_services
  belongs_to :service, inverse_of: :subgrantee_services
end
