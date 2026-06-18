###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'
include ActiveJob::TestHelper

RSpec.describe NotificationsMailer, type: :mailer do
  let(:match_route) do
    route = MatchRoutes::HomelessSetAside.first || create(:homeless_set_aside_route)
    route.update(send_notifications: true) unless route.send_notifications?
    route
  end
  let(:shelter_user) { create(:user) }
  let(:second_shelter_user) { create(:user) }
  let(:decision_user) { create(:user) }
  let(:decline_reason) do
    MatchDecisionReasons::All.where(name: 'Other').first_or_create!
  end
  let(:client) { create(:client) }
  let(:opportunity) { create(:opportunity) }
  let(:shelter_agency_contact) { shelter_user.contact }
  let(:housing_subsidy_admin_contact) { create(:contact, email: 'hsa@example.com') }
  let(:dnd_staff_contact) { create(:contact, email: 'dnd@example.com') }

  let(:match) do
    create(
      :client_opportunity_match,
      client: client,
      opportunity: opportunity,
      match_route: match_route,
      active: true,
      closed: false,
    )
  end

  before do
    ActionMailer::Base.deliveries.clear
    match.shelter_agency_contacts << shelter_agency_contact
    match.housing_subsidy_admin_contacts << housing_subsidy_admin_contact
    match.dnd_staff_contacts << dnd_staff_contact
    # Use test delivery method for NotificationsMailer in tests
    NotificationsMailer.delivery_method = :test
    # Use test queue adapter for ActiveJob
    ActiveJob::Base.queue_adapter = :test
  end

  after do
    # Restore to database delivery method after tests
    NotificationsMailer.delivery_method = :db
  end

  describe '#set_aside_first_step_shelter_agency' do
    let(:notification) do
      Notifications::HomelessSetAside::SetAsideFirstStepShelterAgency.create!(
        match: match,
        recipient: shelter_agency_contact,
      )
    end

    it 'sends email with correct recipient and subject' do
      mail = NotificationsMailer.set_aside_first_step_shelter_agency(notification)

      expect(mail.to).to eq([shelter_agency_contact.email])
      expect(mail.subject).to eq('New Housing Recommendation - Requires Your Action')
    end

    it 'includes match details in email body' do
      mail = NotificationsMailer.set_aside_first_step_shelter_agency(notification)

      expect(mail.body.to_s).to include(shelter_agency_contact.full_name)
      expect(mail.body.to_s).to include('CAS has a new housing recommendation with initial details for your review.')
    end

    it 'includes notification match URL' do
      mail = NotificationsMailer.set_aside_first_step_shelter_agency(notification)

      # Check that the "View details here:" section is present
      expect(mail.body.to_s).to include('View details here:')
    end

    context 'when notification is created during decision initialization' do
      it 'creates notification when SetAsidesHsaAcceptsClient decision is initialized' do
        expect do
          match.set_asides_hsa_accepts_client_decision.initialize_decision!
        end.to change {
          Notifications::HomelessSetAside::SetAsideFirstStepShelterAgency.count
        }.by(1)
      end

      it 'enqueues delivery job when notification is created' do
        expect do
          match.set_asides_hsa_accepts_client_decision.initialize_decision!
        end.to have_enqueued_job.at_least(1).times
      end

      it 'creates notification for each shelter agency contact' do
        match.shelter_agency_contacts << second_shelter_user.contact

        expect do
          match.set_asides_hsa_accepts_client_decision.initialize_decision!
        end.to change {
          Notifications::HomelessSetAside::SetAsideFirstStepShelterAgency.count
        }.by(2)
      end
    end
  end

  describe '#set_aside_match_complete_shelter_agency' do
    let(:notification) do
      Notifications::HomelessSetAside::SetAsideMatchCompleteShelterAgency.create!(
        match: match,
        recipient: shelter_agency_contact,
      )
    end

    it 'sends email with correct recipient and subject and body' do
      mail = NotificationsMailer.set_aside_match_complete_shelter_agency(notification)

      expect(mail.to).to eq([shelter_agency_contact.email])
      expect(mail.subject).to eq('Match Completed')
      expect(mail.body.to_s).to include(shelter_agency_contact.full_name)
      expect(mail.body.to_s).to include('has indicated that a CAS housing recommendation was successfully completed')
    end

    context 'when notification is created during decision completion' do
      before do
        # Initialize the first decision and accept it to move to the next step
        match.set_asides_hsa_accepts_client_decision.initialize_decision!
        match.set_asides_hsa_accepts_client_decision.update!(status: 'accepted')
        match.set_asides_hsa_accepts_client_decision.run_status_callback!(user: decision_user)
      end

      it 'creates notification when SetAsidesRecordClientHousedDateOrDeclineHousingSubsidyAdministrator decision is completed' do
        expect do
          match.set_asides_record_client_housed_date_or_decline_housing_subsidy_administrator_decision.update!(
            status: 'completed',
            client_move_in_date: Date.today,
          )
          match.set_asides_record_client_housed_date_or_decline_housing_subsidy_administrator_decision.run_status_callback!(user: decision_user)
        end.to change {
          Notifications::HomelessSetAside::SetAsideMatchCompleteShelterAgency.count
        }.by(1)
      end

      it 'enqueues delivery job when notification is created' do
        # First decision needs to be accepted before we can complete the second
        # This creates jobs, so we need to clear them first
        match.set_asides_hsa_accepts_client_decision.initialize_decision!
        match.set_asides_hsa_accepts_client_decision.update!(status: 'accepted')
        match.set_asides_hsa_accepts_client_decision.run_status_callback!(user: decision_user)
        clear_enqueued_jobs

        expect do
          match.set_asides_record_client_housed_date_or_decline_housing_subsidy_administrator_decision.update!(
            status: 'completed',
            client_move_in_date: Date.today,
          )
          match.set_asides_record_client_housed_date_or_decline_housing_subsidy_administrator_decision.run_status_callback!(user: decision_user)
        end.to have_enqueued_job.at_least(1).times
      end

      it 'creates notification for each shelter agency contact' do
        match.shelter_agency_contacts << second_shelter_user.contact

        expect do
          match.set_asides_record_client_housed_date_or_decline_housing_subsidy_administrator_decision.update!(
            status: 'completed',
            client_move_in_date: Date.today,
          )
          match.set_asides_record_client_housed_date_or_decline_housing_subsidy_administrator_decision.run_status_callback!(user: decision_user)
        end.to change {
          Notifications::HomelessSetAside::SetAsideMatchCompleteShelterAgency.count
        }.by(2)
      end

      it 'does not create notification when decision is declined' do
        expect do
          match.set_asides_record_client_housed_date_or_decline_housing_subsidy_administrator_decision.update!(
            status: 'declined',
            decline_reason: decline_reason,
            decline_reason_other_explanation: 'Test decline reason explanation',
          )
          match.set_asides_record_client_housed_date_or_decline_housing_subsidy_administrator_decision.run_status_callback!(user: decision_user)
        end.not_to(change { Notifications::HomelessSetAside::SetAsideMatchCompleteShelterAgency.count })
      end
    end
  end

  describe 'end-to-end notification flow' do
    it 'enqueues delivery job and creates notification when HSA accepts client decision is initialized' do
      expect do
        match.set_asides_hsa_accepts_client_decision.initialize_decision!
      end.to have_enqueued_job.at_least(1).times

      notification = Notifications::HomelessSetAside::SetAsideFirstStepShelterAgency
        .where(match: match, recipient: shelter_agency_contact)
        .first

      expect(notification).to be_present
      expect(notification.match).to eq(match)
      expect(notification.recipient).to eq(shelter_agency_contact)
    end

    it 'enqueues delivery job and creates notification when HSA records client housed date' do
      # Initialize and accept first decision
      match.set_asides_hsa_accepts_client_decision.initialize_decision!
      match.set_asides_hsa_accepts_client_decision.update!(status: 'accepted')
      match.set_asides_hsa_accepts_client_decision.run_status_callback!(user: decision_user)
      clear_enqueued_jobs

      # Complete the second decision
      expect do
        match.set_asides_record_client_housed_date_or_decline_housing_subsidy_administrator_decision.update!(
          status: 'completed',
          client_move_in_date: Date.today,
        )
        match.set_asides_record_client_housed_date_or_decline_housing_subsidy_administrator_decision.run_status_callback!(user: decision_user)
      end.to have_enqueued_job.at_least(1).times

      notification = Notifications::HomelessSetAside::SetAsideMatchCompleteShelterAgency
        .where(match: match, recipient: shelter_agency_contact)
        .first

      expect(notification).to be_present
      expect(notification.match).to eq(match)
      expect(notification.recipient).to eq(shelter_agency_contact)
    end
  end
end
