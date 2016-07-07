class SubgranteeService < ActiveRecord::Base
  belongs_to :subgrantee, required: :true, inverse_of: :subgrantee_services
  belongs_to :service, required: :true, inverse_of: :subgrantee_services
end
