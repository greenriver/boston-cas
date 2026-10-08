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

  describe 'recipients' do
    let(:contacts) do
      [:shelter_agency_contacts, :housing_subsidy_admin_contacts, :ssp_contacts, :hsp_contacts, :dnd_staff_contacts].index_with { create(:contact) }
    end

    before { contacts.each { |type, contact| match.send(type) << contact } }

    MatchRoutes::Fourteen.match_steps.each_key do |decision_class|
      it "#{decision_class} notifies its actor type to act and every other contact type FYI" do
        decision = decision_class.constantize.new
        actor_notification, fyi_notification = decision.notifications_for_this_step
        actor = contacts[decision.contact_actor_type]

        expect(actor_notification.notification_recipients_for(match)).to contain_exactly(actor)
        expect(fyi_notification.notification_recipients_for(match)).to match_array(contacts.values - [actor]) if fyi_notification
      end
    end

    (MatchRoutes::Fourteen.match_steps_for_reporting.keys - MatchRoutes::Fourteen.match_steps.keys).each do |decision_class|
      it "#{decision_class} notifies only DND staff" do
        recipients = decision_class.constantize.new.notifications_for_this_step.flat_map { |klass| klass.notification_recipients_for(match) }

        expect(recipients).to contain_exactly(contacts[:dnd_staff_contacts])
      end
    end
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
      contacts.each { |type, contact| match.send(type) << contact }
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
