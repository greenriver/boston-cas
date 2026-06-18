###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

FactoryBot.define do
  factory :project_client, class: 'ProjectClient' do
  end

  factory :hmis_project_client, class: 'ProjectClient' do
    association :data_source, :warehouse
  end

  factory :non_hmis_project_client, class: 'ProjectClient' do
    association :data_source, :deidentified
  end
end
