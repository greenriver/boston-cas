require 'rails_helper'
include ActiveJob::TestHelper

RSpec.describe ClientOpportunityMatch, type: :model do
  let!(:match) { create :client_opportunity_match, active: false }
  let(:priority) { create :priority_vispdat_priority }
  let(:default_route) { create :default_route, match_prioritization: priority }
  let(:provider_route) { create :provider_route, match_prioritization: priority }
  describe "Match initiation on the default route" do
    describe "when the initial user has email schedule set to immediate" do
      let!(:user) { create :user, receive_initial_notification: true, email_schedule: :immediate }
      let!(:program) {
        program = match.sub_program.program
        program.match_route = default_route
        program.save
      }
      it 'a notification is created' do
        match.dnd_staff_contacts << user.contact
        expect {
          match.activate!
        }.to change{
          Notifications::Base.count
        }.by(1)
      end
      it 'a message is added' do
        match.dnd_staff_contacts << user.contact
        perform_enqueued_jobs do
          expect {
            match.activate!
          }.to change{
            Message.count
          }.by(1)
        end
      end
      it 'a notification job is queued' do
        match.dnd_staff_contacts << user.contact
        expect {
          match.activate!
        }.to change{
          ActiveJob::Base.queue_adapter.enqueued_jobs.size
        }.by(1)
      end
      it 'it sends an email' do
        match.dnd_staff_contacts << user.contact
        perform_enqueued_jobs do
          expect {
            match.activate!
          }.to change{
            ActionMailer::Base.deliveries.size
          }.by(1)
        end
      end
    end

    describe "when the initial user has email schedule set to daily" do
      let!(:user) { create :user, receive_initial_notification: true, email_schedule: :daily }
      let!(:program) {
        program = match.sub_program.program
        program.match_route = default_route
        program.save
      }
      it 'a notification is created' do
        match.dnd_staff_contacts << user.contact

        expect {
          match.activate!
        }.to change{
          Notifications::Base.count
        }.by(1)
      end
      it 'a message is added' do
        match.dnd_staff_contacts << user.contact
        perform_enqueued_jobs do
          expect {
            match.activate!
          }.to change{
            Message.count
          }.by(1)
        end
      end
      it 'a notification job is queued' do
        match.dnd_staff_contacts << user.contact
        expect {
          match.activate!
        }.to change{
          ActiveJob::Base.queue_adapter.enqueued_jobs.size
        }.by(1)
      end
      it 'it does not send an email' do
        match.dnd_staff_contacts << user.contact
        perform_enqueued_jobs do
          expect {
            match.activate!
          }.to change{
            ActionMailer::Base.deliveries.size
          }.by(0)
        end
      end
      it 'running digest daily sends an email' do
        match.dnd_staff_contacts << user.contact
        perform_enqueued_jobs do
          expect {
            match.activate!
            MessageJob.new('daily').perform
          }.to change{
            ActionMailer::Base.deliveries.size
          }.by(1)
        end
      end
    end
  end

  describe "Match initiation on the provider only route" do
    describe "when the initial user has email schedule set to immediate" do
      let!(:user) { create :user, receive_initial_notification: true, email_schedule: :immediate }
      let!(:program) {
        program = match.sub_program.program
        program.match_route = provider_route
        program.save
      }
      it 'a notification is created' do
        match.housing_subsidy_admin_contacts << user.contact
        expect {
          match.activate!
        }.to change{
          Notifications::Base.count
        }.by(1)
      end
      it 'a message is added' do
        match.housing_subsidy_admin_contacts << user.contact
        perform_enqueued_jobs do
          expect {
            match.activate!
          }.to change{
            Message.count
          }.by(1)
        end
      end
      it 'a notification job is queued' do
        match.housing_subsidy_admin_contacts << user.contact
        expect {
          match.activate!
        }.to change{
          ActiveJob::Base.queue_adapter.enqueued_jobs.size
        }.by(1)
      end
      it 'it sends an email' do
        match.housing_subsidy_admin_contacts << user.contact
        perform_enqueued_jobs do
          expect {
            match.activate!
          }.to change{
            ActionMailer::Base.deliveries.size
          }.by(1)
        end
      end
    end

    describe "when the initial user has email schedule set to daily" do
      let!(:user) { create :user, receive_initial_notification: true, email_schedule: :daily }
      let!(:program) {
        program = match.sub_program.program
        program.match_route = provider_route
        program.save
      }
      it 'a notification is created' do
        match.housing_subsidy_admin_contacts << user.contact

        expect {
          match.activate!
        }.to change{
          Notifications::Base.count
        }.by(1)
      end
      it 'a notification job is queued' do
        match.housing_subsidy_admin_contacts << user.contact
        expect {
          match.activate!
        }.to change{
          ActiveJob::Base.queue_adapter.enqueued_jobs.size
        }.by(1)
      end
      it 'a message is added' do
        match.housing_subsidy_admin_contacts << user.contact
        perform_enqueued_jobs do
          expect {
            match.activate!
          }.to change{
            Message.count
          }.by(1)
        end
      end
      it 'it does not send an email' do
        match.housing_subsidy_admin_contacts << user.contact
        perform_enqueued_jobs do
          expect {
            match.activate!
          }.to change{
            ActionMailer::Base.deliveries.size
          }.by(0)
        end
      end
      it 'running digest daily sends an email' do
        match.housing_subsidy_admin_contacts << user.contact
        perform_enqueued_jobs do
          expect {
            match.activate!
            MessageJob.new('daily').perform
          }.to change{
            ActionMailer::Base.deliveries.size
          }.by(1)
        end
      end
    end
  end
end
