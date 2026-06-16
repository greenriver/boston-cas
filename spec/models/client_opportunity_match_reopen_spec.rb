###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClientOpportunityMatch, type: :model do
  describe '#reopen!' do
    let(:contact) { create :contact }

    # Set a decision's status directly, bypassing callbacks/validations, so we
    # can reconstruct a precise historical match state.
    def set_status(decision, status, administrative_cancel_reason: nil)
      attrs = { status: status }
      attrs[:administrative_cancel_reason_id] = administrative_cancel_reason.id if administrative_cancel_reason
      decision.update_columns(attrs)
    end

    context 'on a canceled Match Route Thirteen match' do
      let(:route) { MatchRoutes::Thirteen.first }
      let!(:match) do
        create :client_opportunity_match,
               match_route: route,
               active: false,
               closed: true,
               closed_reason: 'canceled'
      end

      context 'with a realistic decision chain canceled at the Hearing Outcome step' do
        # Reproduces the production state from match 412917: the match progressed
        # normally (leaving Match Acknowledgement permanently `acknowledged`) and
        # was then canceled at the Hearing Outcome step with a cancel reason.
        let(:cancel_reason) { MatchDecisionReasons::AdministrativeCancel.create!(name: 'Vacancy filled by other client') }

        before(:each) do
          set_status(match.thirteen_client_match_decision, 'accepted')
          set_status(match.thirteen_match_acknowledgement_decision, 'acknowledged')
          set_status(match.thirteen_client_review_decision, 'accepted')
          set_status(match.thirteen_hearing_scheduled_decision, 'accepted')
          set_status(match.thirteen_hearing_outcome_decision, 'canceled', administrative_cancel_reason: cancel_reason)
        end

        it 'reopens the canceled Hearing Outcome decision' do
          match.reopen!(contact)

          expect(match.thirteen_hearing_outcome_decision.reload.status).to eq('pending')
        end

        it 'leaves every earlier decision untouched' do
          match.reopen!(contact)

          aggregate_failures do
            expect(match.thirteen_client_match_decision.reload.status).to eq('accepted')
            expect(match.thirteen_match_acknowledgement_decision.reload.status).to eq('acknowledged')
            expect(match.thirteen_client_review_decision.reload.status).to eq('accepted')
            expect(match.thirteen_hearing_scheduled_decision.reload.status).to eq('accepted')
          end
        end
      end

      context 'when an earlier decision lingers in an expiration_update status' do
        # `expiration_update` is, like `acknowledged`, one of the statuses
        # current_decision treats as "the active step", so it can mislead reopen
        # the same way.
        before(:each) do
          set_status(match.thirteen_client_match_decision, 'expiration_update')
          set_status(match.thirteen_match_acknowledgement_decision, 'acknowledged')
          set_status(match.thirteen_hearing_outcome_decision, 'canceled')
        end

        it 'reopens the canceled decision and leaves the expiration_update step alone' do
          match.reopen!(contact)

          aggregate_failures do
            expect(match.thirteen_hearing_outcome_decision.reload.status).to eq('pending')
            expect(match.thirteen_client_match_decision.reload.status).to eq('expiration_update')
            expect(match.thirteen_match_acknowledgement_decision.reload.status).to eq('acknowledged')
          end
        end
      end

      context 'when canceled at the initial step before anything is acknowledged' do
        before(:each) do
          set_status(match.thirteen_client_match_decision, 'canceled')
        end

        it 'reopens the canceled initial decision' do
          match.reopen!(contact)

          expect(match.thirteen_client_match_decision.reload.status).to eq('pending')
        end
      end
    end

    context 'on a successful Match Route Thirteen match' do
      let(:route) { MatchRoutes::Thirteen.first }
      let!(:match) do
        create :client_opportunity_match,
               match_route: route,
               active: false,
               closed: true,
               closed_reason: 'success'
      end

      # A fully successful match: it ran all the way through, leaving Match
      # Acknowledgement permanently `acknowledged` and the final Confirm Match
      # Success decision `confirmed`.
      before(:each) do
        set_status(match.thirteen_client_match_decision, 'accepted')
        set_status(match.thirteen_match_acknowledgement_decision, 'acknowledged')
        set_status(match.thirteen_client_review_decision, 'accepted')
        set_status(match.thirteen_hearing_scheduled_decision, 'accepted')
        set_status(match.thirteen_hearing_outcome_decision, 'accepted')
        set_status(match.thirteen_hsa_review_decision, 'accepted')
        set_status(match.thirteen_accept_referral_decision, 'accepted')
        set_status(match.thirteen_confirm_match_success_decision, 'confirmed')
      end

      it 'reopens the success decision, not an earlier acknowledged step' do
        match.reopen!(contact)

        aggregate_failures do
          expect(match.thirteen_confirm_match_success_decision.reload.status).to eq('pending')
          expect(match.thirteen_match_acknowledgement_decision.reload.status).to eq('acknowledged')
        end
      end
    end

    context 'on a canceled Default route match' do
      let(:route) { MatchRoutes::Default.first }
      let!(:match) do
        create :client_opportunity_match,
               match_route: route,
               active: false,
               closed: true,
               closed_reason: 'canceled'
      end

      # Proves the fix is not Route-Thirteen-specific: an earlier
      # Shelter Agency step left in expiration_update must not be reopened in
      # place of the later canceled HSA approval step.
      before(:each) do
        set_status(match.match_recommendation_dnd_staff_decision, 'accepted')
        set_status(match.match_recommendation_shelter_agency_decision, 'expiration_update')
        set_status(match.approve_match_housing_subsidy_admin_decision, 'canceled')
      end

      it 'reopens the canceled HSA approval decision, not the earlier expiration_update step' do
        match.reopen!(contact)

        aggregate_failures do
          expect(match.approve_match_housing_subsidy_admin_decision.reload.status).to eq('pending')
          expect(match.match_recommendation_shelter_agency_decision.reload.status).to eq('expiration_update')
          expect(match.match_recommendation_dnd_staff_decision.reload.status).to eq('accepted')
        end
      end
    end
  end
end
