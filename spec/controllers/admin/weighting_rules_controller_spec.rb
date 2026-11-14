###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::WeightingRulesController, type: :controller do
  # rule_params permits only requirements_attributes, so there is no other attribute to save.
  describe 'PATCH #update requirements' do
    let(:route) { MatchRoutes::Default.first }
    let(:requirement_owner) { create(:weighting_rule, route: route) }
    let(:changed_attributes) { {} }
    let(:minimal_role_attributes) { { can_manage_config: true } }
    let(:send_request) do
      ->(requirements) do
        patch :update, params: {
          match_route_id: route.id,
          on: :member, # the route is declared with a stray `on: :member` default
          id: requirement_owner.id,
          weighting_rule: { requirements_attributes: requirements },
        }
      end
    end

    it_behaves_like 'assignable requirements', other_attribute: false
  end
end
