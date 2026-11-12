###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FundingSourcesController, type: :controller do
  describe 'PATCH #update requirements' do
    let(:requirement_owner) { create(:funding_source, name: 'Old Name') }
    let(:changed_attributes) { { name: 'New Name' } }
    let(:minimal_role_attributes) { { can_view_funding_sources: true, can_edit_funding_sources: true } }
    let(:send_request) do
      ->(requirements) do
        patch :update, params: { id: requirement_owner.id, funding_source: { name: 'New Name', requirements_attributes: requirements } }
      end
    end

    it_behaves_like 'assignable requirements'
  end
end
