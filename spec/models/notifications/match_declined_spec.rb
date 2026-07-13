###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

# Regression tests for routes 4, 7, 8, 9 MatchDeclined subclasses.
#
# DND staff receive their own confirmation step, so they are excluded from this
# notification. If that exclusion is ever lost (e.g. during a refactor), these
# tests catch it.
RSpec.describe 'Match declined notifications', type: :model do
  {
    'Four' => Notifications::Four::MatchDeclined,
    'Seven' => Notifications::Seven::MatchDeclined,
    'Eight' => Notifications::Eight::MatchDeclined,
    'Nine' => Notifications::Nine::MatchDeclined,
  }.each do |route_name, notification_class|
    describe "Notifications::#{route_name}::MatchDeclined.create_for_match!" do
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

      it 'notifies contacts but excludes DND staff' do
        notification_class.create_for_match!(match)

        recipient_ids = notification_class.where(client_opportunity_match_id: match.id).pluck(:recipient_id)
        expect(recipient_ids).to contain_exactly(contact.id)
      end
    end
  end
end
