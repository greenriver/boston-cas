###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

FactoryBot.define do
  factory :identified_client do
    first_name { 'Client' }
    last_name { 'Last' }
  end
end
