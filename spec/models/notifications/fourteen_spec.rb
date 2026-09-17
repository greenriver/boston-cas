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

  it 'each has_decision notification association points at a class its step sends' do
    route.class.match_steps_for_reporting.each_key do |name|
      key = name.demodulize.underscore
      association_class = match.association("#{key}_notifications").klass
      expect(name.constantize.new.notifications_for_this_step).to include(association_class), "#{key}_notifications is #{association_class} but the step does not send it"
    end
  end

  describe 'notifications created when a step is initialized' do
    let(:shelter) { create :contact }
    let(:hsa) { create :contact }
    let(:ssp) { create :contact }
    let(:contacts) { { shelter_agency_contacts: shelter, housing_subsidy_admin_contacts: hsa, ssp_contacts: ssp, hsp_contacts: hsp, dnd_staff_contacts: dnd } }

    def created_pairs
      Notifications::Base.where(client_opportunity_match_id: match.id).map { |n| [n.class, n.recipient] }
    end

    before do
      # Only contacts with an active user are notification recipients.
      contacts.each_value { |contact| create(:user, contact: contact) }
      match.shelter_agency_contacts << shelter
      match.housing_subsidy_admin_contacts << hsa
      match.ssp_contacts << ssp
      route.update!(send_notifications: false)
    end

    after { route.update!(send_notifications: true) }

    it 'Eligibility Screening notifies the HSP to act and every other contact type FYI' do
      match.fourteen_eligibility_screening_decision.initialize_decision!

      expect(created_pairs).to contain_exactly(
        [Notifications::Fourteen::FourteenEligibilityScreeningHsp, hsp],
        [Notifications::Fourteen::FourteenEligibilityScreeningFyi, shelter],
        [Notifications::Fourteen::FourteenEligibilityScreeningFyi, hsa],
        [Notifications::Fourteen::FourteenEligibilityScreeningFyi, ssp],
        [Notifications::Fourteen::FourteenEligibilityScreeningFyi, dnd],
      )
    end

    it 'Eligibility Screening Decline notifies only DND staff' do
      match.fourteen_eligibility_screening_decline_decision.initialize_decision!

      expect(created_pairs).to contain_exactly([Notifications::Fourteen::FourteenEligibilityScreeningDecline, dnd])
    end

    it 'Initiate Match notifies only DND staff' do
      match.fourteen_initiate_match_decision.initialize_decision!

      expect(created_pairs).to contain_exactly([Notifications::Fourteen::FourteenInitiateMatchDndStaff, dnd])
    end

    it 'initializing with send_notifications: false creates nothing' do
      match.fourteen_eligibility_screening_decision.initialize_decision!(send_notifications: false)

      expect(created_pairs).to be_empty
    end
  end
end
