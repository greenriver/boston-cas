###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

# Regression tests for routes 4, 5, 7, 8, 9 MatchCanceled subclasses.
#
# These classes inherit from Notifications::MatchCanceled (which excludes DND staff and
# conditionally excludes HSA/SSP/HSP contacts) but override notification_recipients_for
# to send to all contacts instead — if that override is ever lost, these tests catch it.
RSpec.describe 'Match canceled notifications', type: :model do
  {
    'Four' => Notifications::Four::MatchCanceled,
    'Five' => Notifications::Five::MatchCanceled,
    'Seven' => Notifications::Seven::MatchCanceled,
    'Eight' => Notifications::Eight::MatchCanceled,
    'Nine' => Notifications::Nine::MatchCanceled,
  }.each do |route_name, notification_class|
    describe "Notifications::#{route_name}::MatchCanceled.create_for_match!" do
      let(:route) do
        "MatchRoutes::#{route_name}".constantize.first.tap do |r|
          r.update!(send_notifications: false)
        end
      end
      let(:program) { create(:program, match_route: route) }
      let(:sub_program) { create(:sub_program, program: program) }
      let(:voucher) { create(:voucher, sub_program: sub_program) }
      let(:opportunity) { create(:opportunity, voucher: voucher) }
      let(:match) { create(:client_opportunity_match, match_route: route, opportunity: opportunity) }
      let(:contact) { create(:contact) }
      let(:dnd_contact) { create(:contact) }
      let!(:contact_user) { create(:user, contact: contact) }
      let!(:dnd_user) { create(:user, contact: dnd_contact) }

      before do
        match.contacts << contact
        match.dnd_staff_contacts << dnd_contact
      end

      it 'does not raise a NameError' do
        expect { notification_class.create_for_match!(match) }.not_to raise_error
      end

      it 'creates a notification for each contact (including DND staff)' do
        expect do
          notification_class.create_for_match!(match)
        end.to change { notification_class.count }.by(2)
      end

      it 'creates notifications of the correct subclass type, not the base class' do
        notification_class.create_for_match!(match)

        expect(notification_class.where(client_opportunity_match_id: match.id).count).to eq(2)
      end

      it 'accepts a decision_id keyword argument without error' do
        expect { notification_class.create_for_match!(match, decision_id: 99) }.not_to raise_error
      end
    end
  end

  describe 'Notifications::MatchCanceled.create_for_match!' do
    let(:route) { MatchRoutes::Default.first.tap { |r| r.update!(send_notifications: false) } }
    let(:match) { create(:client_opportunity_match, match_route: route) }
    let(:contact) { create(:contact) }
    let(:dnd_contact) { create(:contact) }
    let(:hsa_contact) { create(:contact) }
    let!(:contact_user) { create(:user, contact: contact) }
    let!(:dnd_user) { create(:user, contact: dnd_contact) }
    let!(:hsa_user) { create(:user, contact: hsa_contact) }

    before do
      match.contacts << contact
      match.dnd_staff_contacts << dnd_contact
      match.housing_subsidy_admin_contacts << hsa_contact
    end

    it 'excludes DND staff contacts' do
      Notifications::MatchCanceled.create_for_match!(match)

      recipient_ids = Notifications::MatchCanceled.where(client_opportunity_match_id: match.id).pluck(:recipient_id)
      expect(recipient_ids).not_to include(dnd_contact.id)
    end

    it 'excludes housing subsidy admin contacts when the HSA has not been involved' do
      Notifications::MatchCanceled.create_for_match!(match)

      recipient_ids = Notifications::MatchCanceled.where(client_opportunity_match_id: match.id).pluck(:recipient_id)
      expect(recipient_ids).to contain_exactly(contact.id)
    end

    it 'includes housing subsidy admin contacts when the HSA has been involved' do
      create(
        :match_decisions_match_recommendation_shelter_agency,
        match: match,
        status: 'accepted',
        client_spoken_with_services_agency: true,
        cori_release_form_submitted: true,
      )

      Notifications::MatchCanceled.create_for_match!(match)

      recipient_ids = Notifications::MatchCanceled.where(client_opportunity_match_id: match.id).pluck(:recipient_id)
      expect(recipient_ids).to contain_exactly(contact.id, hsa_contact.id)
    end
  end
end
