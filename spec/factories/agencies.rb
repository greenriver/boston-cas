###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

FactoryBot.define do
  factory :agency, class: 'Agency' do
    sequence(:name) { |n| "Agency #{n}" }
  end
end
