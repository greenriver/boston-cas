require 'rails_helper'
include ActiveJob::TestHelper

RSpec.describe ClientOpportunityMatch, type: :model do
  let!(:match) { create :client_opportunity_match, active: false }
  let(:priority) { create :priority_vispdat_priority }
  let(:provider_route) { create :provider_route, match_prioritization: priority }
  let(:default_route) { create :default_route, match_prioritization: priority, routes_parked_on_active_match: [provider_route.class.to_s], routes_parked_on_successful_match: MatchRoutes::Base.all_routes.map(&:name) }
  describe 'Match initiation on the default route' do
    describe 'when the initial user has email schedule set to immediate' do
      let!(:user) { create :user, receive_initial_notification: true, email_schedule: :immediate }
      let!(:program) do
        program = match.sub_program.program
        program.match_route = default_route
        program.save

        match.match_route = program.match_route
        match.save
      end
      it 'a notification is created' do
        match.dnd_staff_contacts << user.contact
        expect do
          match.activate!(user: user)
        end.to change {
          Notifications::Base.count
        }.by(1)
      end
      it 'a message is added' do
        match.dnd_staff_contacts << user.contact
        perform_enqueued_jobs do
          expect do
            match.activate!(user: user)
          end.to change {
            Message.count
          }.by(1)
        end
      end
      it 'a notification job is queued' do
        match.dnd_staff_contacts << user.contact
        expect do
          match.activate!(user: user)
        end.to change {
          ActiveJob::Base.queue_adapter.enqueued_jobs.size
        }.by(1)
      end
      it 'it sends an email' do
        match.dnd_staff_contacts << user.contact
        perform_enqueued_jobs do
          expect do
            match.activate!(user: user)
          end.to change {
            ActionMailer::Base.deliveries.size
          }.by(1)
        end
      end
      it 'generates an unavailable for on the route on activation' do
        match.activate!(user: user)
        aggregate_failures do
          expect(UnavailableAsCandidateFor.count).to eq(1)
          expect(UnavailableAsCandidateFor.first.match_route_type).to eq(provider_route.class.name)
          expect(UnavailableAsCandidateFor.first.reason).to eq(UnavailableAsCandidateFor::ACTIVE_MATCH_TEXT)
          expect(UnavailableAsCandidateFor.first.user_id).to eq(user.id)
          expect(UnavailableAsCandidateFor.first.match_id).to eq(match.id)
        end
      end
      it 'removes unavailable for created by activation upon the match being canceled' do
        match_client = Client.find(match.client_id)
        match_client.make_unavailable_in(match_route: default_route, expires_at: nil, user: user, match: match, reason: UnavailableAsCandidateFor::PARKED_TEXT)
        match.activate!(user: user)
        expect(match_client.unavailable_as_candidate_fors.count).to eq(2)
        expect(match_client.unavailable_as_candidate_fors.where(reason: UnavailableAsCandidateFor::ACTIVE_MATCH_TEXT).count).to eq(1)
        match.canceled!
        expect(match_client.unavailable_as_candidate_fors.count).to eq(1)
        expect(match_client.unavailable_as_candidate_fors.where(reason: UnavailableAsCandidateFor::ACTIVE_MATCH_TEXT).count).to eq(0)
      end
      it 'removes unavailable for created by activation upon the match being rejected' do
        match_client = Client.find(match.client_id)
        match_client.make_unavailable_in(match_route: default_route, expires_at: nil, user: user, match: match, reason: UnavailableAsCandidateFor::PARKED_TEXT)
        match.activate!(user: user)
        expect(match_client.unavailable_as_candidate_fors.count).to eq(2)
        expect(match_client.unavailable_as_candidate_fors.where(reason: UnavailableAsCandidateFor::ACTIVE_MATCH_TEXT).count).to eq(1)
        match.rejected!
        expect(match_client.unavailable_as_candidate_fors.count).to eq(1)
        expect(match_client.unavailable_as_candidate_fors.where(reason: UnavailableAsCandidateFor::ACTIVE_MATCH_TEXT).count).to eq(0)
      end
      it 'removes unavailable for created by activation upon the match being poached' do
        match_client = Client.find(match.client_id)
        match_client.make_unavailable_in(match_route: default_route, expires_at: nil, user: user, match: match, reason: UnavailableAsCandidateFor::PARKED_TEXT)
        match.activate!(user: user)
        expect(match_client.unavailable_as_candidate_fors.count).to eq(2)
        expect(match_client.unavailable_as_candidate_fors.where(reason: UnavailableAsCandidateFor::ACTIVE_MATCH_TEXT).count).to eq(1)
        match.poached!
        expect(match_client.unavailable_as_candidate_fors.count).to eq(1)
        expect(match_client.unavailable_as_candidate_fors.where(reason: UnavailableAsCandidateFor::ACTIVE_MATCH_TEXT).count).to eq(0)
      end
      it 'generates an unavailable for on the route on success' do
        match.succeeded!(user: user)
        aggregate_failures do
          expect(UnavailableAsCandidateFor.count).to eq(MatchRoutes::Base.all_routes.count)
          expect(UnavailableAsCandidateFor.pluck(:match_route_type).sort).to eq(MatchRoutes::Base.all_routes.map(&:name).sort)
          expect(UnavailableAsCandidateFor.pluck(:reason).uniq).to eq([UnavailableAsCandidateFor::SUCCESSFUL_MATCH_TEXT])
          expect(UnavailableAsCandidateFor.pluck(:user_id).uniq).to eq([user.id])
          expect(UnavailableAsCandidateFor.pluck(:match_id).uniq).to eq([match.id])
        end
      end
    end

    describe 'when the initial user has email schedule set to daily' do
      let!(:user) { create :user, receive_initial_notification: true, email_schedule: :daily }
      let!(:program) do
        program = match.sub_program.program
        program.match_route = default_route
        program.save

        match.match_route = program.match_route
        match.save
      end
      it 'a notification is created' do
        match.dnd_staff_contacts << user.contact

        expect do
          match.activate!(user: user)
        end.to change {
          Notifications::Base.count
        }.by(1)
      end
      it 'a message is added' do
        match.dnd_staff_contacts << user.contact
        perform_enqueued_jobs do
          expect do
            match.activate!(user: user)
          end.to change {
            Message.count
          }.by(1)
        end
      end
      it 'a notification job is queued' do
        match.dnd_staff_contacts << user.contact
        expect do
          match.activate!(user: user)
        end.to change {
          ActiveJob::Base.queue_adapter.enqueued_jobs.size
        }.by(1)
      end
      it 'it does not send an email' do
        match.dnd_staff_contacts << user.contact
        perform_enqueued_jobs do
          expect do
            match.activate!(user: user)
          end.to change {
            ActionMailer::Base.deliveries.size
          }.by(0)
        end
      end
      it 'running digest daily sends an email' do
        match.dnd_staff_contacts << user.contact
        perform_enqueued_jobs do
          expect do
            match.activate!(user: user)
            MessageJob.new('daily').perform
          end.to change {
            ActionMailer::Base.deliveries.size
          }.by(1)
        end
      end
    end
  end

  describe 'Match initiation on the provider only route' do
    describe 'when the initial user has email schedule set to immediate' do
      let!(:user) { create :user, receive_initial_notification: true, email_schedule: :immediate }
      let!(:program) do
        program = match.sub_program.program
        program.match_route = provider_route
        program.save

        match.match_route = program.match_route
        match.save
      end
      it 'a notification is created' do
        match.housing_subsidy_admin_contacts << user.contact
        expect do
          match.activate!(user: user)
        end.to change {
          Notifications::Base.count
        }.by(1)
      end
      it 'a message is added' do
        match.housing_subsidy_admin_contacts << user.contact
        perform_enqueued_jobs do
          expect do
            match.activate!(user: user)
          end.to change {
            Message.count
          }.by(1)
        end
      end
      it 'a notification job is queued' do
        match.housing_subsidy_admin_contacts << user.contact
        expect do
          match.activate!(user: user)
        end.to change {
          ActiveJob::Base.queue_adapter.enqueued_jobs.size
        }.by(1)
      end
      it 'it sends an email' do
        match.housing_subsidy_admin_contacts << user.contact
        perform_enqueued_jobs do
          expect do
            match.activate!(user: user)
          end.to change {
            ActionMailer::Base.deliveries.size
          }.by(1)
        end
      end
    end

    describe 'when the initial user has email schedule set to daily' do
      let!(:user) { create :user, receive_initial_notification: true, email_schedule: :daily }
      let!(:program) do
        program = match.sub_program.program
        program.match_route = provider_route
        program.save

        match.match_route = program.match_route
        match.save
      end
      it 'a notification is created' do
        match.housing_subsidy_admin_contacts << user.contact

        expect do
          match.activate!(user: user)
        end.to change {
          Notifications::Base.count
        }.by(1)
      end
      it 'a notification job is queued' do
        match.housing_subsidy_admin_contacts << user.contact
        expect do
          match.activate!(user: user)
        end.to change {
          ActiveJob::Base.queue_adapter.enqueued_jobs.size
        }.by(1)
      end
      it 'a message is added' do
        match.housing_subsidy_admin_contacts << user.contact
        perform_enqueued_jobs do
          expect do
            match.activate!(user: user)
          end.to change {
            Message.count
          }.by(1)
        end
      end
      it 'it does not send an email' do
        match.housing_subsidy_admin_contacts << user.contact
        perform_enqueued_jobs do
          expect do
            match.activate!(user: user)
          end.to change {
            ActionMailer::Base.deliveries.size
          }.by(0)
        end
      end
      it 'running digest daily sends an email' do
        match.housing_subsidy_admin_contacts << user.contact
        perform_enqueued_jobs do
          expect do
            match.activate!(user: user)
            MessageJob.new('daily').perform
          end.to change {
            ActionMailer::Base.deliveries.size
          }.by(1)
        end
      end
    end
  end
end
