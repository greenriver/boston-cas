###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Notifications::Fourteen', type: :model do
  let(:route) { MatchRoutes::Fourteen.first }
  let(:match) { create :client_opportunity_match, match_route: route }
  let(:hsp) { create :contact }
  let(:dnd) { create :contact }

  before do
    match.hsp_contacts << hsp
    match.dnd_staff_contacts << dnd
  end

  it 'FYI notifications go to everyone except the acting contact type' do
    recipients = Notifications::Fourteen::FourteenEligibilityScreeningFyi.notification_recipients_for(match)
    expect(recipients).to include(dnd)
    expect(recipients).not_to include(hsp)
  end

  it 'actor notifications go only to the acting contact type' do
    recipients = Notifications::Fourteen::FourteenEligibilityScreeningHsp.notification_recipients_for(match)
    expect(recipients).to contain_exactly(hsp)
  end

  it 'every route-14 notification has a mailer method and a template' do
    Notifications::Fourteen.constants.map { |c| Notifications::Fourteen.const_get(c) }.each do |klass|
      type = klass.new.notification_type
      expect(NotificationsMailer.instance_methods).to include(type.to_sym), "missing mailer method #{type}"
      expect(Rails.root.join('app', 'views', 'notifications_mailer', "#{type}.text.haml")).to exist, "missing template #{type}"
    end
  end

  it 'every step notification class is referenced by its decision' do
    referenced = route.class.match_steps_for_reporting.keys.flat_map { |name| name.constantize.new.notifications_for_this_step }
    expect(referenced.map(&:name)).to match_array(Notifications::Fourteen.constants.map { |c| "Notifications::Fourteen::#{c}" })
  end
end
