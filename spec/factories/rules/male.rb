###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

FactoryBot.define do
  factory :rules_male, class: 'Rules::Male' do
    name { 'Male' }
    type { 'Rules::Male' }
    verb { 'be' }
  end
end