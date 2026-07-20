###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

FactoryBot.define do
  factory :weighting_rule, class: 'WeightingRule' do
    # MatchRoutes::Default is seeded in spec_helper via MatchRoutes::Base.ensure_all
    route { MatchRoutes::Default.first }
  end
end
