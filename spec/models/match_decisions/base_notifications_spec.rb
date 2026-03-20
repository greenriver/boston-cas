# frozen_string_literal: true

###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

require 'rails_helper'
include ActiveJob::TestHelper

RSpec.describe MatchDecisions::Base, type: :model do
  describe '#notify_contact_of_action_taken_on_behalf_of' do
    let(:route) do
      r = MatchRoutes::Default.first
      r.update(send_notifications: true) unless r.send_notifications?
      r
    end
    let(:program) { create(:program, match_route: route) }
    let(:sub_program) { create(:sub_program, program: program) }
    let(:voucher) { create(:voucher, sub_program: sub_program) }
    let(:opportunity) { create(:opportunity, voucher: voucher) }
    let(:match) { create(:client_opportunity_match, match_route: route, opportunity: opportunity, active: true) }
    let(:shelter_contact) { create(:contact, email: 'shelter@example.com') }
    let(:admin_contact) { create(:contact, email: 'admin@example.com') }

    before do
      match.shelter_agency_contacts << shelter_contact
      ActiveJob::Base.queue_adapter = :test
    end

    context 'when decision has notify_on_behalf_of? true' do
      let(:decision) do
        create(
          :match_decisions_match_recommendation_shelter_agency,
          match: match,
          status: 'accepted',
          contact: admin_contact,
          client_spoken_with_services_agency: true,
          cori_release_form_submitted: true,
          release_of_information: '1',
        )
      end

      it 'creates OnBehalfOf notifications for contact_actor_type' do
        expect do
          decision.notify_contact_of_action_taken_on_behalf_of contact: admin_contact
        end.to change { Notifications::OnBehalfOf.count }.by(1)
      end

      it 'passes decision_id to OnBehalfOf.create_for_match!' do
        perform_enqueued_jobs do
          decision.notify_contact_of_action_taken_on_behalf_of contact: admin_contact
        end

        event = MatchEvents::NotificationDelivery.find_by(
          match_id: match.id,
          notification: Notifications::OnBehalfOf.last,
        )
        expect(event.decision_id).to eq(decision.id)
      end
    end

    context 'when decision has skip_notify_on_behalf_of_when_canceled? true and status is canceled' do
      let(:decision) do
        create(
          :match_decisions_match_recommendation_shelter_agency,
          :cancel_reason,
          match: match,
          status: 'canceled',
          contact: admin_contact,
        )
      end

      it 'does not create OnBehalfOf notifications' do
        expect do
          decision.notify_contact_of_action_taken_on_behalf_of contact: admin_contact
        end.not_to(change { Notifications::OnBehalfOf.count })
      end
    end
  end

  describe '.backfill_decision_id_on_events!' do
    let(:route) do
      r = MatchRoutes::Default.first
      r.update(send_notifications: false)
      r
    end
    let(:program) { create(:program, match_route: route) }
    let(:sub_program) { create(:sub_program, program: program) }
    let(:voucher) { create(:voucher, sub_program: sub_program) }
    let(:opportunity) { create(:opportunity, voucher: voucher) }
    let(:match) { create(:client_opportunity_match, match_route: route, opportunity: opportunity) }
    let(:shelter_contact) { create(:contact, email: 'shelter@example.com') }
    let(:decision) { match.match_recommendation_shelter_agency_decision }

    before do
      match.shelter_agency_contacts << shelter_contact
      decision.update!(
        status: 'accepted',
        client_spoken_with_services_agency: true,
        cori_release_form_submitted: true,
        release_of_information: '1',
      )
    end

    it 'updates notification_delivery_events with nil decision_id to use decision id' do
      notification = Notifications::MatchRecommendationShelterAgency.create!(
        match: match,
        recipient: shelter_contact,
      )
      event = notification.notification_delivery_events.create!(
        match: match,
        contact: shelter_contact,
        decision_id: nil,
      )

      MatchDecisions::Base.backfill_decision_id_on_events!

      expect(event.reload.decision_id).to eq(decision.id)
    end
  end
end
