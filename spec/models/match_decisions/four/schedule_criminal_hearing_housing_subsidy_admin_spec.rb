###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MatchDecisions::Four::ScheduleCriminalHearingHousingSubsidyAdmin, type: :model do
  let(:match_route) { MatchRoutes::Four.first || create(:route_four) }
  let(:match) { create(:client_opportunity_match, match_route: match_route) }
  let(:decision) { match.four_schedule_criminal_hearing_housing_subsidy_admin_decision }
  let(:confirm_decision) { match.four_confirm_schedule_criminal_hearing_decline_dnd_staff_decision }
  let(:decline_reason) { MatchDecisionReasons::All.where(name: 'Self-resolved').first_or_create! }
  let(:admin_contact) do
    user = create(:user)
    user.roles << create(:admin_role)
    user.contact
  end

  before do
    decision.initialize_decision!(send_notifications: false)
  end

  describe 'validations' do
    it 'requires a decline_reason when declined' do
      decision.assign_attributes(status: 'declined', decline_reason: nil)
      expect(decision).not_to be_valid
      expect(decision.errors[:decline_reason]).to be_present
    end

    it 'is valid when declined with a decline_reason' do
      decision.assign_attributes(status: 'declined', decline_reason: decline_reason)
      expect(decision).to be_valid
    end

    it 'rejects a criminal_hearing_date when declined' do
      decision.assign_attributes(status: 'declined', decline_reason: decline_reason, criminal_hearing_date: Date.tomorrow)
      expect(decision).not_to be_valid
      expect(decision.errors[:criminal_hearing_date]).to be_present
    end
  end

  describe 'StatusCallbacks#declined' do
    before do
      match.housing_subsidy_admin_contacts << admin_contact
    end

    it 'notifies contacts and initializes a new confirm-decline decision' do
      decision.update!(status: 'declined', decline_reason: decline_reason)

      expect do
        decision.run_status_callback!(user: admin_contact)
      end.to change { Notifications::Four::MatchDeclined.count }.by(1)

      expect(confirm_decision.reload.status).to eq('pending')
    end

    it 'does not create a second confirm-decline decision if one already exists' do
      confirm_decision.update!(status: 'decline_overridden_returned')

      decision.update!(status: 'declined', decline_reason: decline_reason)

      expect do
        decision.run_status_callback!(user: admin_contact)
      end.not_to(change { MatchDecisions::Four::ConfirmScheduleCriminalHearingDeclineDndStaff.where(match: match).count })

      expect(confirm_decision.reload.status).to eq('pending')
    end

    it 'creates a confirm-decline decision for a match that predates this decision type' do
      confirm_decision.destroy
      match.reload # clear the cached has_one association so the callback sees it as missing

      decision.update!(status: 'declined', decline_reason: decline_reason)

      expect do
        decision.run_status_callback!(user: admin_contact)
      end.to change {
        MatchDecisions::Four::ConfirmScheduleCriminalHearingDeclineDndStaff.where(match: match).count
      }.by(1)

      expect(match.reload.four_confirm_schedule_criminal_hearing_decline_dnd_staff_decision.status).to eq('pending')
    end
  end
end
