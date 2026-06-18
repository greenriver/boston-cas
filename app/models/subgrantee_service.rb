###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class SubgranteeService < ApplicationRecord
  belongs_to :subgrantee, inverse_of: :subgrantee_services
  belongs_to :service, inverse_of: :subgrantee_services
end
