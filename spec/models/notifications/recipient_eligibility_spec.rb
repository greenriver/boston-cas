###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Notification recipient eligibility', type: :model do
  include ActiveJob::TestHelper

  let(:route) do
    MatchRoutes::Default.first.tap { |r| r.update!(send_notifications: true) }
  end
  let(:match) { create(:client_opportunity_match, match_route: route) }

  let(:eligible_contact) { create(:contact) }
  let!(:eligible_user) { create(:user, contact: eligible_contact) }
  let(:no_user_contact) { create(:contact) }
  let(:inactive_contact) { create(:contact) }
  let!(:inactive_user) { create(:user, contact: inactive_contact, active: false) }

  before do
    ActiveJob::Base.queue_adapter = :test
    ActionMailer::Base.deliveries.clear
  end

  shared_examples 'notification delivery for eligible contacts only' do |notification_class|
    it 'creates a notification only for the contact with an active user' do
      expect do
        notification_class.create_for_match!(match)
      end.to change(notification_class, :count).by(1)

      expect(notification_class.last.recipient).to eq(eligible_contact)
    end

    it 'delivers email only for the contact with an active user' do
      perform_enqueued_jobs do
        expect do
          notification_class.create_for_match!(match)
        end.to change { ActionMailer::Base.deliveries.size }.by(1)
      end

      expect(ActionMailer::Base.deliveries.last.to).to include(eligible_contact.email)
    end
  end

  describe Notifications::MatchRecommendationShelterAgency do
    before do
      match.shelter_agency_contacts << eligible_contact
      match.shelter_agency_contacts << no_user_contact
      match.shelter_agency_contacts << inactive_contact
    end

    include_examples 'notification delivery for eligible contacts only', Notifications::MatchRecommendationShelterAgency
  end

  describe Notifications::MatchRecommendationClient do
    before do
      match.client_contacts << eligible_contact
      match.client_contacts << no_user_contact
      match.client_contacts << inactive_contact
    end

    include_examples 'notification delivery for eligible contacts only', Notifications::MatchRecommendationClient
  end

  describe Notifications::MatchCanceled do
    before do
      match.contacts << eligible_contact
      match.contacts << no_user_contact
      match.contacts << inactive_contact
    end

    include_examples 'notification delivery for eligible contacts only', Notifications::MatchCanceled
  end

  describe Notifications::Eight::MatchCanceled do
    let(:route) do
      MatchRoutes::Eight.first.tap { |r| r.update!(send_notifications: true) }
    end
    let(:program) { create(:program, match_route: route) }
    let(:sub_program) { create(:sub_program, program: program) }
    let(:voucher) { create(:voucher, sub_program: sub_program) }
    let(:opportunity) { create(:opportunity, voucher: voucher) }
    let(:match) { create(:client_opportunity_match, match_route: route, opportunity: opportunity) }
    let(:dnd_contact) { create(:contact) }
    let!(:dnd_user) { create(:user, contact: dnd_contact) }

    before do
      match.contacts << eligible_contact
      match.contacts << no_user_contact
      match.dnd_staff_contacts << dnd_contact
    end

    it 'creates notifications for all eligible contacts, including DND staff' do
      expect do
        Notifications::Eight::MatchCanceled.create_for_match!(match)
      end.to change(Notifications::Eight::MatchCanceled, :count).by(2)
    end
  end

  describe Notifications::NoteSent do
    it 'creates a notification when the contact has an active user' do
      expect do
        Notifications::NoteSent.create_for_match!(
          match_id: match.id,
          contact_id: eligible_contact.id,
          note: 'Hello',
        )
      end.to change(Notifications::NoteSent, :count).by(1)
    end

    it 'does not create a notification when the contact has no user' do
      expect do
        Notifications::NoteSent.create_for_match!(
          match_id: match.id,
          contact_id: no_user_contact.id,
          note: 'Hello',
        )
      end.not_to change(Notifications::NoteSent, :count)
    end

    it 'does not create a notification when the contact user is inactive' do
      expect do
        Notifications::NoteSent.create_for_match!(
          match_id: match.id,
          contact_id: inactive_contact.id,
          note: 'Hello',
        )
      end.not_to change(Notifications::NoteSent, :count)
    end
  end

  describe Notifications::ProgressUpdateRequested do
    it 'creates a notification when the contact has an active user' do
      expect do
        Notifications::ProgressUpdateRequested.create_for_match!(
          match_id: match.id,
          contact_id: eligible_contact.id,
        )
      end.to change(Notifications::ProgressUpdateRequested, :count).by(1)
    end

    it 'does not create a notification when the contact has no user' do
      expect do
        Notifications::ProgressUpdateRequested.create_for_match!(
          match_id: match.id,
          contact_id: no_user_contact.id,
        )
      end.not_to change(Notifications::ProgressUpdateRequested, :count)
    end
  end

  describe '.recreate_for_match!' do
    it 'creates a notification when the contact has an active user' do
      expect do
        Notifications::MatchRecommendationShelterAgency.recreate_for_match!(match, eligible_contact)
      end.to change(Notifications::MatchRecommendationShelterAgency, :count).by(1)
    end

    it 'does not create a notification when the contact has no user' do
      expect do
        Notifications::MatchRecommendationShelterAgency.recreate_for_match!(match, no_user_contact)
      end.not_to change(Notifications::MatchRecommendationShelterAgency, :count)
    end
  end

  describe 'DatabaseDelivery' do
    it 'stores and sends a message when the contact has an active user' do
      expect do
        TestDatabaseMailer.ping(eligible_contact.email).deliver_now
      end.to change(Message, :count).by(1)
        .and change { ActionMailer::Base.deliveries.size }.by(1)
    end

    it 'does not store or send a message when the contact has no user' do
      expect do
        TestDatabaseMailer.ping(no_user_contact.email).deliver_now
      end.to change(Message, :count).by(0)
        .and change { ActionMailer::Base.deliveries.size }.by(0)
    end

    it 'does not store or send a message when the contact user is inactive' do
      expect do
        TestDatabaseMailer.ping(inactive_contact.email).deliver_now
      end.to change(Message, :count).by(0)
        .and change { ActionMailer::Base.deliveries.size }.by(0)
    end
  end

  describe ClientMailer do
    it 'sends to the client email without requiring a contact or user record' do
      client = create(:client, email: 'client@example.com', send_emails: true)
      client_match = create(:client_opportunity_match, client: client, match_route: route)

      expect do
        ClientMailer.new_match(client_match).deliver_now
      end.to change { ActionMailer::Base.deliveries.size }.by(1)

      expect(ActionMailer::Base.deliveries.last.to).to include('client@example.com')
    end
  end
end
