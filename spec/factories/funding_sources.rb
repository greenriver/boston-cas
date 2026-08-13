###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

FactoryBot.define do
  factory :funding_source, class: 'FundingSource' do
    name { 'Test Funding Source' }
  end
end
