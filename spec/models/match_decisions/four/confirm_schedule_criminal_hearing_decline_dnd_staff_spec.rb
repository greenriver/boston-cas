###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MatchDecisions::Four::ConfirmScheduleCriminalHearingDeclineDndStaff, type: :model do
  let(:match_route) { MatchRoutes::Four.first || create(:route_four) }
  let(:match) { create(:client_opportunity_match, match_route: match_route) }
  let(:decision) { match.four_confirm_schedule_criminal_hearing_decline_dnd_staff_decision }
  let(:admin_contact) do
    user = create(:user)
    user.roles << create(:admin_role)
    user.contact
  end
  let(:plain_contact) { create(:contact) }

  describe '#accessible_by?' do
    it 'is accessible to a contact whose user can reject or approve matches' do
      expect(decision.accessible_by?(admin_contact)).to be(true)
    end

    it 'is not accessible to a contact with no matching permission' do
      expect(decision.accessible_by?(plain_contact)).to be_falsey
    end
  end

  describe '#notifications_for_this_step' do
    it 'notifies DND for review plus the standard HSA-decision stakeholders' do
      expect(decision.notifications_for_this_step).to contain_exactly(
        Notifications::Four::ConfirmScheduleCriminalHearingDeclineDndStaff,
        Notifications::HousingSubsidyAdminDecisionClient,
        Notifications::HousingSubsidyAdminDecisionSsp,
        Notifications::HousingSubsidyAdminDecisionHsp,
        Notifications::HousingSubsidyAdminDecisionDevelopmentOfficer,
        Notifications::HousingSubsidyAdminDeclinedMatchShelterAgency,
      )
    end
  end

  describe 'StatusCallbacks' do
    before do
      match.dnd_staff_contacts << admin_contact
      decision.initialize_decision!(send_notifications: false)
    end

    describe '#decline_overridden' do
      it 're-initializes the original ScheduleCriminalHearingHousingSubsidyAdmin decision' do
        decision.update!(status: 'decline_overridden')
        expect do
          decision.run_status_callback!(user: admin_contact)
        end.to change {
          match.four_schedule_criminal_hearing_housing_subsidy_admin_decision.reload.status
        }.to('pending')
      end
    end

    describe '#decline_overridden_returned' do
      it 're-initializes the original decision and uninitializes itself' do
        decision.update!(status: 'decline_overridden_returned')
        decision.run_status_callback!(user: admin_contact)

        aggregate_failures do
          expect(match.four_schedule_criminal_hearing_housing_subsidy_admin_decision.reload.status).to eq('pending')
          expect(decision.reload.status).to be_nil
        end
      end
    end

    describe '#decline_confirmed' do
      it 'rejects the match and notifies contacts' do
        decision.update!(status: 'decline_confirmed')

        expect do
          decision.run_status_callback!(user: admin_contact)
        end.to change { Notifications::Four::MatchRejected.count }.by(1)

        aggregate_failures do
          expect(match.reload.closed?).to be(true)
          expect(match.closed_reason).to eq('rejected')
        end
      end
    end

    describe '#canceled' do
      it 'cancels the match' do
        decision.update!(status: 'canceled', administrative_cancel_reason: MatchDecisionReasons::All.where(name: 'Other').first_or_create!)
        decision.run_status_callback!(user: admin_contact)

        aggregate_failures do
          expect(match.reload.closed?).to be(true)
          expect(match.closed_reason).to eq('canceled')
        end
      end
    end
  end
end
