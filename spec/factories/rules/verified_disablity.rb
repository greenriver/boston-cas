###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

FactoryBot.define do
  factory :rules_verified_disability, class: 'Rules::VerifiedDisability' do
    name { 'Verified disability' }
    type { 'Rules::VerifiedDisability' }
    verb { 'have' }
  end
end