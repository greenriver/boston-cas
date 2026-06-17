###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

FactoryBot.define do
  factory :rules_female, class: 'Rules::Female' do
    name { 'Female' }
    type { 'Rules::Female' }
    verb { 'be' }
  end
end