###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MatchProgressUpdates::Base, type: :model do
  let(:route) { MatchRoutes::Default.first }
  let(:match) { create(:client_opportunity_match, match_route: route) }

  describe '.send_notifications' do
    before do
      allow(NotificationsMailer).to receive(:progress_update_requested).and_return(double(deliver_later: true))
    end

    it 'does not raise when the stalled contact has no user' do
      contact = create(:contact)
      allow(described_class).to receive(:contacts_for_stalled_matches).and_return({ contact.id => Set.new([match.id]) })

      expect { described_class.send_notifications }.not_to raise_error
      expect(Notifications::ProgressUpdateRequested.count).to eq(0)
      expect(NotificationsMailer).not_to have_received(:progress_update_requested)
    end

    it 'does not raise when the stalled contact has an inactive user' do
      contact = create(:contact)
      create(:user, contact: contact, active: false)
      allow(described_class).to receive(:contacts_for_stalled_matches).and_return({ contact.id => Set.new([match.id]) })

      expect { described_class.send_notifications }.not_to raise_error
      expect(Notifications::ProgressUpdateRequested.count).to eq(0)
      expect(NotificationsMailer).not_to have_received(:progress_update_requested)
    end

    it 'notifies the stalled contact when they have an active user' do
      contact = create(:contact)
      create(:user, contact: contact)
      allow(described_class).to receive(:contacts_for_stalled_matches).and_return({ contact.id => Set.new([match.id]) })

      described_class.send_notifications

      notification = Notifications::ProgressUpdateRequested.last
      expect(notification.recipient).to eq(contact)
      expect(NotificationsMailer).to have_received(:progress_update_requested).with([notification.id])
      expect(notification.notification_delivery_events.count).to eq(1)
      expect(match.reload.stall_contacts_notified).to be_present
    end
  end

  describe '.batch_should_notify_dnd' do
    before do
      allow(NotificationsMailer).to receive(:dnd_progress_update_late).and_return(double(deliver_later: true))
    end

    it 'does not raise when the dnd contact has no user' do
      contact = create(:contact)
      allow(described_class).to receive(:dnd_contacts_for_late_stalled_matches).and_return({ contact.id => Set.new([match.id]) })

      expect { described_class.batch_should_notify_dnd }.not_to raise_error
      expect(Notifications::DndProgressUpdateLate.count).to eq(0)
      expect(NotificationsMailer).not_to have_received(:dnd_progress_update_late)
    end

    it 'does not raise when the dnd contact has an inactive user' do
      contact = create(:contact)
      create(:user, contact: contact, active: false)
      allow(described_class).to receive(:dnd_contacts_for_late_stalled_matches).and_return({ contact.id => Set.new([match.id]) })

      expect { described_class.batch_should_notify_dnd }.not_to raise_error
      expect(Notifications::DndProgressUpdateLate.count).to eq(0)
      expect(NotificationsMailer).not_to have_received(:dnd_progress_update_late)
    end

    it 'notifies the dnd contact when they have an active user' do
      contact = create(:contact)
      create(:user, contact: contact)
      allow(described_class).to receive(:dnd_contacts_for_late_stalled_matches).and_return({ contact.id => Set.new([match.id]) })

      described_class.batch_should_notify_dnd

      notification = Notifications::DndProgressUpdateLate.last
      expect(notification.recipient).to eq(contact)
      expect(NotificationsMailer).to have_received(:dnd_progress_update_late).with([notification.id])
      expect(notification.notification_delivery_events.count).to eq(1)
      expect(match.reload.dnd_notified).to be_present
    end
  end
end
