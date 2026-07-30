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
    route = MatchRoutes::Four.first || create(:route_four)
    route.update(send_notifications: true) unless route.send_notifications?
    route
  end
  let(:decision_user) { create(:user) }
  let(:decline_reason) { MatchDecisionReasons::All.where(name: 'Self-resolved').first_or_create! }
  # Notification recipients must have an active user (Contact#notification_recipient?),
  # so these can't be bare `create(:contact, ...)` records.
  let(:dnd_staff_contact) { create(:user).contact }
  let(:housing_subsidy_admin_contact) { create(:user).contact }

  let(:match) { create(:client_opportunity_match, match_route: match_route) }
  # Notifications::Base::DeliverJob is a private_constant; const_get is the
  # standard way to reach it for job-matcher assertions.
  let(:deliver_job_class) { Notifications::Base.const_get(:DeliverJob) }

  before do
    ActionMailer::Base.deliveries.clear
    match.dnd_staff_contacts << dnd_staff_contact
    match.housing_subsidy_admin_contacts << housing_subsidy_admin_contact
    NotificationsMailer.delivery_method = :test
    ActiveJob::Base.queue_adapter = :test
  end

  after do
    NotificationsMailer.delivery_method = :db
  end

  describe '#confirm_record_client_housed_date_decline_dnd_staff' do
    let(:notification) do
      Notifications::Four::ConfirmRecordClientHousedDateDeclineDndStaff.create!(
        match: match,
        recipient: dnd_staff_contact,
      )
    end

    it 'sends email with correct recipient and subject' do
      mail = NotificationsMailer.confirm_record_client_housed_date_decline_dnd_staff(notification)

      expect(mail.to).to eq([dnd_staff_contact.email])
      expect(mail.subject).to eq("Match Declined by #{Translation.translate('HSA')} - Requires Your Action")
    end

    it 'includes recipient name and decline/confirmation context in the email body' do
      mail = NotificationsMailer.confirm_record_client_housed_date_decline_dnd_staff(notification)

      expect(mail.body.to_s).to include(dnd_staff_contact.full_name)
      expect(mail.body.to_s).to include("A #{Translation.translate('Housing Subsidy Administrator')} has declined a housing match.")
      expect(mail.body.to_s).to include("The match now requires #{Translation.translate('DND')} confirmation")
    end

    context 'when the housing subsidy administrator declines after recording a housed date' do
      before do
        match.four_record_client_housed_date_housing_subsidy_administrator_decision.initialize_decision!(send_notifications: false)
        match.four_record_client_housed_date_housing_subsidy_administrator_decision.update!(status: 'declined', decline_reason: decline_reason)
      end

      it 'creates the notification only for dnd staff contacts, not the housing subsidy administrator' do
        match.four_record_client_housed_date_housing_subsidy_administrator_decision.run_status_callback!(user: decision_user)

        recipients = Notifications::Four::ConfirmRecordClientHousedDateDeclineDndStaff.where(match: match).pluck(:recipient_id)
        expect(recipients).to contain_exactly(dnd_staff_contact.id)
      end

      it 'creates one notification per dnd staff contact' do
        match.dnd_staff_contacts << create(:user).contact

        expect do
          match.four_record_client_housed_date_housing_subsidy_administrator_decision.run_status_callback!(user: decision_user)
        end.to change {
          Notifications::Four::ConfirmRecordClientHousedDateDeclineDndStaff.count
        }.by(2)
      end

      it 'enqueues a delivery job for the new confirm-decline notification' do
        expect do
          match.four_record_client_housed_date_housing_subsidy_administrator_decision.run_status_callback!(user: decision_user)
        end.to have_enqueued_job(deliver_job_class).with(an_instance_of(Notifications::Four::ConfirmRecordClientHousedDateDeclineDndStaff), anything)
      end
    end
  end

  describe '#confirm_schedule_criminal_hearing_decline_dnd_staff' do
    let(:notification) do
      Notifications::Four::ConfirmScheduleCriminalHearingDeclineDndStaff.create!(
        match: match,
        recipient: dnd_staff_contact,
      )
    end

    it 'sends email with correct recipient and subject' do
      mail = NotificationsMailer.confirm_schedule_criminal_hearing_decline_dnd_staff(notification)

      expect(mail.to).to eq([dnd_staff_contact.email])
      expect(mail.subject).to eq("Match Declined by #{Translation.translate('HSA')} - Requires Your Action")
    end

    it 'includes recipient name and decline/confirmation context in the email body' do
      mail = NotificationsMailer.confirm_schedule_criminal_hearing_decline_dnd_staff(notification)

      expect(mail.body.to_s).to include(dnd_staff_contact.full_name)
      expect(mail.body.to_s).to include("A #{Translation.translate('Housing Subsidy Administrator')} has declined a housing match.")
      expect(mail.body.to_s).to include("The match now requires #{Translation.translate('DND')} confirmation")
    end

    context 'when the housing subsidy administrator declines while scheduling the criminal hearing' do
      before do
        match.four_schedule_criminal_hearing_housing_subsidy_admin_decision.initialize_decision!(send_notifications: false)
        match.four_schedule_criminal_hearing_housing_subsidy_admin_decision.update!(status: 'declined', decline_reason: decline_reason)
      end

      it 'creates the notification only for dnd staff contacts, not the housing subsidy administrator' do
        match.four_schedule_criminal_hearing_housing_subsidy_admin_decision.run_status_callback!(user: decision_user)

        recipients = Notifications::Four::ConfirmScheduleCriminalHearingDeclineDndStaff.where(match: match).pluck(:recipient_id)
        expect(recipients).to contain_exactly(dnd_staff_contact.id)
      end

      it 'creates one notification per dnd staff contact' do
        match.dnd_staff_contacts << create(:user).contact

        expect do
          match.four_schedule_criminal_hearing_housing_subsidy_admin_decision.run_status_callback!(user: decision_user)
        end.to change {
          Notifications::Four::ConfirmScheduleCriminalHearingDeclineDndStaff.count
        }.by(2)
      end

      it 'enqueues a delivery job for the new confirm-decline notification' do
        expect do
          match.four_schedule_criminal_hearing_housing_subsidy_admin_decision.run_status_callback!(user: decision_user)
        end.to have_enqueued_job(deliver_job_class).with(an_instance_of(Notifications::Four::ConfirmScheduleCriminalHearingDeclineDndStaff), anything)
      end
    end
  end
end
