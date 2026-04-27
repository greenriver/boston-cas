# frozen_string_literal: true

###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

require 'rails_helper'
include ActiveJob::TestHelper

RSpec.describe Notifications::Base, type: :model do
  describe '.create_for_match!' do
    let(:route) do
      r = MatchRoutes::Default.first
      r.update(send_notifications: true) unless r.send_notifications?
      r
    end
    let(:match) do
      create(:client_opportunity_match, match_route: route)
    end
    let(:shelter_contact) { create(:contact, email: 'shelter@example.com') }
    let(:decision) do
      create(
        :match_decisions_match_recommendation_shelter_agency,
        match: match,
        status: 'accepted',
        client_spoken_with_services_agency: true,
        cori_release_form_submitted: true,
        release_of_information: '1',
      )
    end

    before do
      match.shelter_agency_contacts << shelter_contact
      ActiveJob::Base.queue_adapter = :test
    end

    it 'passes decision_id to notifications and stores it on delivery events' do
      perform_enqueued_jobs do
        Notifications::MatchRecommendationShelterAgency.create_for_match!(match, decision_id: decision.id)
      end

      notification = Notifications::MatchRecommendationShelterAgency.find_by(
        client_opportunity_match_id: match.id,
        recipient: shelter_contact,
      )
      event = notification.notification_delivery_events.last
      expect(event.decision_id).to eq(decision.id)
    end
  end

  describe '#record_delivery_event!' do
    let(:route) do
      r = MatchRoutes::Default.first
      r.update(send_notifications: false)
      r
    end
    let(:match) { create(:client_opportunity_match, match_route: route) }
    let(:contact) { create(:contact, email: 'test@example.com') }

    it 'stores decision_id on the delivery event when provided' do
      notification = Notifications::MatchRecommendationShelterAgency.create!(
        match: match,
        recipient: contact,
      )
      decision_id = 42
      notification.record_delivery_event!(decision_id: decision_id)

      event = notification.notification_delivery_events.last
      expect(event.decision_id).to eq(decision_id)
    end

    it 'allows nil decision_id when notification has no associated decision' do
      notification = Notifications::OnBehalfOf.create!(
        match: match,
        recipient: contact,
      )
      notification.record_delivery_event!(decision_id: nil)

      event = notification.notification_delivery_events.last
      expect(event.decision_id).to be_nil
    end
  end
end
