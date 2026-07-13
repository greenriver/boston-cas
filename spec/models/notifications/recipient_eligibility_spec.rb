###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Notification recipient eligibility', type: :model do
  include ActiveJob::TestHelper

  let(:eligible_contact) { create(:contact) }
  let!(:eligible_user) { create(:user, contact: eligible_contact) }
  let(:no_user_contact) { create(:contact) }
  let(:inactive_contact) { create(:contact) }
  let!(:inactive_user) { create(:user, contact: inactive_contact, active: false) }

  before do
    ActiveJob::Base.queue_adapter = :test
    ActionMailer::Base.deliveries.clear
  end

  shared_examples 'notification recipient eligibility' do |notification_class, contact_association: :contacts|
    it 'creates a notification when the contact has an active user' do
      test_match = create_eligibility_match
      test_match.public_send(contact_association) << eligible_contact

      expect do
        notification_class.create_for_match!(test_match)
      end.to change(notification_class, :count).by(1)

      expect(notification_class.last.recipient).to eq(eligible_contact)
    end

    it 'does not create a notification when the contact has no user' do
      test_match = create_eligibility_match
      test_match.public_send(contact_association) << no_user_contact

      expect do
        notification_class.create_for_match!(test_match)
      end.not_to change(notification_class, :count)
    end

    it 'does not create a notification when the contact user is inactive' do
      test_match = create_eligibility_match
      test_match.public_send(contact_association) << inactive_contact

      expect do
        notification_class.create_for_match!(test_match)
      end.not_to change(notification_class, :count)
    end
  end

  shared_examples 'notification recipient eligibility by contact_id' do |notification_class|
    it 'creates a notification when the contact has an active user' do
      test_match = create_eligibility_match

      expect do
        notification_class.create_for_match!(
          match_id: test_match.id,
          contact_id: eligible_contact.id,
        )
      end.to change(notification_class, :count).by(1)
    end

    it 'does not create a notification when the contact has no user' do
      test_match = create_eligibility_match

      expect do
        notification_class.create_for_match!(
          match_id: test_match.id,
          contact_id: no_user_contact.id,
        )
      end.not_to change(notification_class, :count)
    end

    it 'does not create a notification when the contact user is inactive' do
      test_match = create_eligibility_match

      expect do
        notification_class.create_for_match!(
          match_id: test_match.id,
          contact_id: inactive_contact.id,
        )
      end.not_to change(notification_class, :count)
    end
  end

  def create_match_for_route(route_name, send_notifications: false)
    route = "MatchRoutes::#{route_name}".constantize.first.tap { |r| r.update!(send_notifications: send_notifications) }
    program = create(:program, match_route: route)
    sub_program = create(:sub_program, program: program)
    voucher = create(:voucher, sub_program: sub_program)
    opportunity = create(:opportunity, voucher: voucher)
    create(:client_opportunity_match, match_route: route, opportunity: opportunity)
  end

  describe Notifications::MatchRecommendationShelterAgency do
    let(:route) { MatchRoutes::Default.first.tap { |r| r.update!(send_notifications: true) } }

    def create_eligibility_match
      create(:client_opportunity_match, match_route: route)
    end

    include_examples 'notification recipient eligibility',
                     Notifications::MatchRecommendationShelterAgency,
                     contact_association: :shelter_agency_contacts
  end

  describe Notifications::MatchRecommendationClient do
    let(:route) { MatchRoutes::Default.first.tap { |r| r.update!(send_notifications: true) } }

    def create_eligibility_match
      create(:client_opportunity_match, match_route: route)
    end

    include_examples 'notification recipient eligibility',
                     Notifications::MatchRecommendationClient,
                     contact_association: :client_contacts
  end

  describe Notifications::MatchCanceled do
    let(:route) { MatchRoutes::Default.first.tap { |r| r.update!(send_notifications: false) } }

    def create_eligibility_match
      create(:client_opportunity_match, match_route: route)
    end

    include_examples 'notification recipient eligibility', Notifications::MatchCanceled
  end

  {
    'Four' => Notifications::Four::MatchCanceled,
    'Five' => Notifications::Five::MatchCanceled,
    'Seven' => Notifications::Seven::MatchCanceled,
    'Eight' => Notifications::Eight::MatchCanceled,
    'Nine' => Notifications::Nine::MatchCanceled,
  }.each do |route_name, notification_class|
    describe notification_class do
      let(:current_route_name) { route_name }

      def create_eligibility_match
        create_match_for_route(current_route_name)
      end

      include_examples 'notification recipient eligibility', notification_class
    end
  end

  {
    'Four' => Notifications::Four::MatchDeclined,
    'Seven' => Notifications::Seven::MatchDeclined,
    'Eight' => Notifications::Eight::MatchDeclined,
    'Nine' => Notifications::Nine::MatchDeclined,
  }.each do |route_name, notification_class|
    describe notification_class do
      let(:current_route_name) { route_name }

      def create_eligibility_match
        create_match_for_route(current_route_name)
      end

      include_examples 'notification recipient eligibility', notification_class
    end
  end

  describe Notifications::OnBehalfOf do
    let(:route) { MatchRoutes::Default.first.tap { |r| r.update!(send_notifications: false) } }

    def create_eligibility_match
      create(:client_opportunity_match, match_route: route)
    end

    it 'creates a notification when the contact has an active user' do
      test_match = create_eligibility_match
      test_match.shelter_agency_contacts << eligible_contact

      expect do
        Notifications::OnBehalfOf.create_for_match!(test_match, :shelter_agency_contacts)
      end.to change(Notifications::OnBehalfOf, :count).by(1)
    end

    it 'does not create a notification when the contact has no user' do
      test_match = create_eligibility_match
      test_match.shelter_agency_contacts << no_user_contact

      expect do
        Notifications::OnBehalfOf.create_for_match!(test_match, :shelter_agency_contacts)
      end.not_to change(Notifications::OnBehalfOf, :count)
    end

    it 'does not create a notification when the contact user is inactive' do
      test_match = create_eligibility_match
      test_match.shelter_agency_contacts << inactive_contact

      expect do
        Notifications::OnBehalfOf.create_for_match!(test_match, :shelter_agency_contacts)
      end.not_to change(Notifications::OnBehalfOf, :count)
    end
  end

  describe Notifications::MatchInitiationForManualNotification do
    let(:route) { MatchRoutes::Default.first.tap { |r| r.update!(send_notifications: false) } }
    let(:alternate_matches_role) { create(:role, can_see_alternate_matches: true) }
    let(:eligible_contact) { create(:contact) }
    let!(:eligible_user) do
      create(:user, contact: eligible_contact).tap { |user| user.roles << alternate_matches_role }
    end

    def create_eligibility_match
      create(:client_opportunity_match, match_route: route)
    end

    it 'creates a notification when the contact has an active user' do
      test_match = create_eligibility_match
      test_match.dnd_staff_contacts << eligible_contact

      expect do
        Notifications::MatchInitiationForManualNotification.create_for_match!(test_match)
      end.to change(Notifications::MatchInitiationForManualNotification, :count).by(1)
    end

    it 'does not create a notification when the contact has no user' do
      test_match = create_eligibility_match
      test_match.dnd_staff_contacts << no_user_contact

      expect do
        Notifications::MatchInitiationForManualNotification.create_for_match!(test_match)
      end.not_to change(Notifications::MatchInitiationForManualNotification, :count)
    end

    it 'does not create a notification when the contact user is inactive' do
      test_match = create_eligibility_match
      test_match.dnd_staff_contacts << inactive_contact

      expect do
        Notifications::MatchInitiationForManualNotification.create_for_match!(test_match)
      end.not_to change(Notifications::MatchInitiationForManualNotification, :count)
    end
  end

  describe Notifications::NoteSent do
    let(:route) { MatchRoutes::Default.first.tap { |r| r.update!(send_notifications: false) } }

    def create_eligibility_match
      create(:client_opportunity_match, match_route: route)
    end

    it 'creates a notification when the contact has an active user' do
      test_match = create_eligibility_match

      expect do
        Notifications::NoteSent.create_for_match!(
          match_id: test_match.id,
          contact_id: eligible_contact.id,
          note: 'Hello',
        )
      end.to change(Notifications::NoteSent, :count).by(1)
    end

    it 'does not create a notification when the contact has no user' do
      test_match = create_eligibility_match

      expect do
        Notifications::NoteSent.create_for_match!(
          match_id: test_match.id,
          contact_id: no_user_contact.id,
          note: 'Hello',
        )
      end.not_to change(Notifications::NoteSent, :count)
    end

    it 'does not create a notification when the contact user is inactive' do
      test_match = create_eligibility_match

      expect do
        Notifications::NoteSent.create_for_match!(
          match_id: test_match.id,
          contact_id: inactive_contact.id,
          note: 'Hello',
        )
      end.not_to change(Notifications::NoteSent, :count)
    end
  end

  describe Notifications::ProgressUpdateRequested do
    let(:route) { MatchRoutes::Default.first.tap { |r| r.update!(send_notifications: false) } }

    def create_eligibility_match
      create(:client_opportunity_match, match_route: route)
    end

    include_examples 'notification recipient eligibility by contact_id', Notifications::ProgressUpdateRequested
  end

  describe Notifications::DndProgressUpdateLate do
    let(:route) { MatchRoutes::Default.first.tap { |r| r.update!(send_notifications: false) } }

    def create_eligibility_match
      create(:client_opportunity_match, match_route: route)
    end

    include_examples 'notification recipient eligibility by contact_id', Notifications::DndProgressUpdateLate
  end

  describe '.recreate_for_match!' do
    let(:route) { MatchRoutes::Default.first.tap { |r| r.update!(send_notifications: false) } }
    let(:match) { create(:client_opportunity_match, match_route: route) }

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

    it 'does not create a notification when the contact user is inactive' do
      expect do
        Notifications::MatchRecommendationShelterAgency.recreate_for_match!(match, inactive_contact)
      end.not_to change(Notifications::MatchRecommendationShelterAgency, :count)
    end
  end

  describe MatchProgressUpdates::ShelterAgency do
    let(:route) { MatchRoutes::Default.first.tap { |r| r.update!(send_notifications: false) } }

    def create_eligibility_match
      create(:client_opportunity_match, match_route: route)
    end

    it 'creates a progress update when the contact has an active user' do
      test_match = create_eligibility_match
      test_match.shelter_agency_contacts << eligible_contact

      expect do
        MatchProgressUpdates::ShelterAgency.create_for_match!(test_match)
      end.to change(MatchProgressUpdates::ShelterAgency, :count).by(1)
    end

    it 'does not create a progress update when the contact has no user' do
      test_match = create_eligibility_match
      test_match.shelter_agency_contacts << no_user_contact

      expect do
        MatchProgressUpdates::ShelterAgency.create_for_match!(test_match)
      end.not_to change(MatchProgressUpdates::ShelterAgency, :count)
    end

    it 'does not create a progress update when the contact user is inactive' do
      test_match = create_eligibility_match
      test_match.shelter_agency_contacts << inactive_contact

      expect do
        MatchProgressUpdates::ShelterAgency.create_for_match!(test_match)
      end.not_to change(MatchProgressUpdates::ShelterAgency, :count)
    end
  end

  describe ClientOpportunityMatch do
    describe '.send_summary_emails' do
      let(:route) { MatchRoutes::Default.first }
      let(:config) { create(:config) }

      before do
        allow(Config).to receive(:last).and_return(config)
        allow(config).to receive(:never_send_match_summary_email?).and_return(false)
        allow(config).to receive(:send_match_summary_email_on).and_return(Date.current.wday)
      end

      it 'sends a weekly digest when the contact has an active user' do
        summary_contact = create(:contact)
        create(:user, contact: summary_contact, receive_weekly_match_summary_email: true)
        match = create(:client_opportunity_match, match_route: route, active: true)
        match.contacts << summary_contact

        expect(MatchDigestMailer).to receive(:digest).with(summary_contact).and_return(double(deliver_now: true))

        ClientOpportunityMatch.send_summary_emails
      end

      it 'does not send a weekly digest when the contact has no user' do
        contact_without_user = create(:contact)
        match_without_user = create(:client_opportunity_match, match_route: route, active: true)
        match_without_user.contacts << contact_without_user

        allow(ClientOpportunityMatch).to receive(:active).and_return(ClientOpportunityMatch.where(id: match_without_user.id))

        expect(MatchDigestMailer).not_to receive(:digest)

        ClientOpportunityMatch.send_summary_emails
      end

      it 'does not send a weekly digest when the contact user is inactive' do
        summary_contact = create(:contact)
        create(:user, contact: summary_contact, receive_weekly_match_summary_email: true, active: false)
        match = create(:client_opportunity_match, match_route: route, active: true)
        match.contacts << summary_contact

        allow(ClientOpportunityMatch).to receive(:active).and_return(ClientOpportunityMatch.where(id: match.id))

        expect(MatchDigestMailer).not_to receive(:digest)

        ClientOpportunityMatch.send_summary_emails
      end
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
    let(:route) { MatchRoutes::Default.first }

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
