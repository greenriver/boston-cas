###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

# Regression tests for routes 4, 5, 7, 8, 9 MatchCanceled subclasses.
#
# These classes inherit from Notifications::MatchCanceled (which has custom filtering logic)
# but need to use Notifications::Base.create_for_match! directly to send to all contacts.
# They do this via singleton_class.instance_method — if that ever breaks, these tests catch it.
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
end
