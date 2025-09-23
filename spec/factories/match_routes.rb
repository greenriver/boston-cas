###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

FactoryBot.define do
  factory :default_route, class: 'MatchRoutes::Default' do
    active { true }
    association :match_prioritization, factory: :priority_days_homeless
  end
  factory :provider_route, class: 'MatchRoutes::ProviderOnly' do
    active { true }
    association :match_prioritization, factory: :priority_days_homeless
  end
end
