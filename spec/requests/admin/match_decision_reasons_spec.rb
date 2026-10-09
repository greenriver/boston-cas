###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::MatchDecisionReasons', type: :request do
  let!(:admin_role) { create(:admin_role, can_manage_config: true) }
  let!(:admin) { create(:user) }

  before do
    admin.roles << admin_role
    sign_in admin
  end

  describe 'GET index' do
    it 'lists existing reasons' do
      reason = create(:match_decision_reason, name: 'Client Deceased')

      get admin_match_decision_reasons_path

      expect(response.body).to include('Client Deceased')
      expect(response.body).to include(edit_admin_match_decision_reason_path(reason))
    end
  end

  describe 'POST create' do
    it 'creates a new reason in the catalog' do
      expect do
        post admin_match_decision_reasons_path, params: { match_decision_reason: { name: 'New Reason', referral_result: MatchDecisionReasons::Base::CLIENT_REJECTED, active: true } }
      end.to change(MatchDecisionReasons::Base, :count).by(1)

      reason = MatchDecisionReasons::Base.last
      expect(reason.name).to eq('New Reason')
      expect(reason.referral_result).to eq(MatchDecisionReasons::Base::CLIENT_REJECTED)
      expect(response).to redirect_to(admin_match_decision_reasons_path)
    end

    it 're-renders the new form without creating a record when name is blank' do
      expect do
        post admin_match_decision_reasons_path, params: { match_decision_reason: { name: '' } }
      end.not_to change(MatchDecisionReasons::Base, :count)

      expect(response).to render_template(:new)
    end
  end

  describe 'PATCH update' do
    it 'updates the name, referral_result, and active flag' do
      reason = create(:match_decision_reason, name: 'Old Name', active: true, referral_result: nil)

      patch admin_match_decision_reason_path(reason), params: { match_decision_reason: { name: 'Updated Name', referral_result: MatchDecisionReasons::Base::PROVIDER_REJECTED, active: false } }

      reason.reload
      expect(reason.name).to eq('Updated Name')
      expect(reason.referral_result).to eq(MatchDecisionReasons::Base::PROVIDER_REJECTED)
      expect(reason.active).to eq(false)
    end
  end

  describe 'authorization' do
    let!(:limited_role) { create(:role, name: 'limited') }
    let!(:limited_user) { create(:user) }

    before do
      limited_user.roles << limited_role
      sign_in limited_user
    end

    it 'redirects users without can_manage_config' do
      get admin_match_decision_reasons_path

      expect(response).to redirect_to(root_path)
    end

    it 'redirects from GET new without rendering the form' do
      get new_admin_match_decision_reason_path

      expect(response).to redirect_to(root_path)
    end

    it 'redirects from POST create without creating a record' do
      expect do
        post admin_match_decision_reasons_path, params: { match_decision_reason: { name: 'Should not be created' } }
      end.not_to change(MatchDecisionReasons::Base, :count)

      expect(response).to redirect_to(root_path)
    end

    it 'redirects from GET edit without rendering the form' do
      reason = create(:match_decision_reason, name: 'Existing Reason')

      get edit_admin_match_decision_reason_path(reason)

      expect(response).to redirect_to(root_path)
    end

    it 'redirects from PATCH update without changing the record' do
      reason = create(:match_decision_reason, name: 'Existing Reason', active: true)

      patch admin_match_decision_reason_path(reason), params: { match_decision_reason: { name: 'Changed Name' } }

      expect(reason.reload.name).to eq('Existing Reason')
      expect(response).to redirect_to(root_path)
    end
  end
end
