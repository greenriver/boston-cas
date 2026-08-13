###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
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
  factory :homeless_set_aside_route, class: 'MatchRoutes::HomelessSetAside' do
    active { true }
    association :match_prioritization, factory: :priority_days_homeless
  end
  factory :route_four, class: 'MatchRoutes::Four' do
    active { true }
    association :match_prioritization, factory: :priority_days_homeless
  end
end
