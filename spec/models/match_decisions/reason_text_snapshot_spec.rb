###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

class MatchDecisions::ReasonResolutionSpecStep < MatchDecisions::Base
  include MatchDecisions::AcceptsDeclineReason
end

RSpec.describe 'MatchDecisions reason text snapshotting', type: :model do
  let(:match) { create(:client_opportunity_match) }
  let(:decision) { MatchDecisions::ReasonResolutionSpecStep.create!(match: match) }

  describe 'decline_reason_text' do
    it 'snapshots the reason name when decline_reason is assigned' do
      reason = create(:match_decision_reason, name: 'Client Deceased')
      decision.update!(decline_reason: reason)

      expect(decision.decline_reason_text).to eq('Client Deceased')
    end

    it 'does not change once set, even if the catalog reason is later renamed' do
      reason = create(:match_decision_reason, name: 'Client Deceased')
      decision.update!(decline_reason: reason)

      reason.update!(name: 'Renamed Reason')
      decision.update!(note: 'unrelated change')

      expect(decision.reload.decline_reason_text).to eq('Client Deceased')
    end
  end

  describe 'administrative_cancel_reason_text' do
    it 'snapshots the reason name when administrative_cancel_reason is assigned' do
      reason = create(:match_decision_reason, name: 'Match Expired')
      decision.update!(administrative_cancel_reason: reason)

      expect(decision.administrative_cancel_reason_text).to eq('Match Expired')
    end

    it 'does not change once set, even if the catalog reason is later renamed' do
      reason = create(:match_decision_reason, name: 'Match Expired')
      decision.update!(administrative_cancel_reason: reason)

      reason.update!(name: 'Renamed Reason')
      decision.update!(note: 'unrelated change')

      expect(decision.reload.administrative_cancel_reason_text).to eq('Match Expired')
    end
  end

  describe '#decline_reason_name' do
    it 'uses the frozen snapshot even after the catalog reason is renamed' do
      reason = create(:match_decision_reason, name: 'Client Deceased')
      decision.update!(decline_reason: reason)
      reason.update!(name: 'Renamed Reason')

      expect(decision.reload.decline_reason_name).to eq('Client Deceased')
    end
  end

  describe '#canceled_status_label' do
    it 'uses the frozen snapshot even after the catalog reason is renamed' do
      reason = create(:match_decision_reason, name: 'Match Expired')
      decision.update!(administrative_cancel_reason: reason)
      reason.update!(name: 'Renamed Reason')

      expect(decision.reload.canceled_status_label).to include('Match Expired')
    end
  end
end
