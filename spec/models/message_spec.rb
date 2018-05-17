require 'rails_helper'
include ActiveJob::TestHelper
RSpec.describe Message, type: :model do
  before { clear_enqueued_jobs }
  let!(:contact) { create :contact, email: "noreply@greenriver.com" }

  describe 'When no user is connected to a contact' do
    describe 'Sending a message with deliver_now' do
      it 'creates a message' do 
        expect do
          TestDatabaseMailer.ping(contact.email).deliver_now
        end.to change{Message.count}.by(1)
      end

      it 'sends a message' do
        expect do
          TestDatabaseMailer.ping(contact.email).deliver_now
        end.to change { ActionMailer::Base.deliveries.size }.by(1)
      end
    end

    describe 'Sending a message with deliver_later' do
      it 'enqueues a job' do 
        expect {
          TestDatabaseMailer.ping(contact.email).deliver_later
        }.to have_enqueued_job.on_queue('mailers')
      end

      it 'creates a message' do 
        perform_enqueued_jobs do 
          expect do
            TestDatabaseMailer.ping(contact.email).deliver_later
          end.to change{Message.count}.by(1)
        end
      end

      it 'sends a message' do
        perform_enqueued_jobs do 
          expect do
            TestDatabaseMailer.ping(contact.email).deliver_later
          end.to change { ActionMailer::Base.deliveries.size }.by(1)
        end
      end
    end
  end
  describe 'When user email schedule set to immediate: ' do
    let!(:user) { create :user, contact: contact, email_schedule: 'immediate' }

    describe 'Sending a message with deliver_now' do
      it 'creates a message' do 
        expect do
          TestDatabaseMailer.ping(contact.email).deliver_now
        end.to change{Message.count}.by(1)
      end

      it 'sends a message' do
        expect do
          TestDatabaseMailer.ping(contact.email).deliver_now
        end.to change { ActionMailer::Base.deliveries.size }.by(1)
      end
    end

    describe 'Sending a message with deliver_later' do
      it 'enqueues a job' do 
        expect {
          TestDatabaseMailer.ping(contact.email).deliver_later
        }.to have_enqueued_job.on_queue('mailers')
      end

      it 'creates a message' do 
        perform_enqueued_jobs do 
          expect do
            TestDatabaseMailer.ping(contact.email).deliver_later
          end.to change{Message.count}.by(1)
        end
      end

      it 'sends a message' do
        perform_enqueued_jobs do 
          expect do
            TestDatabaseMailer.ping(contact.email).deliver_later
          end.to change { ActionMailer::Base.deliveries.size }.by(1)
        end
      end
    end
  end

  describe 'When user email schedule set to daily: ' do
    let!(:user) { create :user, contact: contact, email_schedule: 'daily' }

    describe 'Sending a message with deliver_now' do
      it 'creates a message' do 
        expect do
          TestDatabaseMailer.ping(contact.email).deliver_now
        end.to change{Message.count}.by(1)
      end

      it 'does not send a message' do
        expect do
          TestDatabaseMailer.ping(contact.email).deliver_now
        end.to change { ActionMailer::Base.deliveries.size }.by(0)
      end
    end

    describe 'Sending a message with deliver_later' do
      it 'enqueues a job' do 
        expect {
          TestDatabaseMailer.ping(contact.email).deliver_later
        }.to have_enqueued_job.on_queue('mailers')
      end

      it 'creates a message' do 
        perform_enqueued_jobs do 
          expect do
            TestDatabaseMailer.ping(contact.email).deliver_later
          end.to change{Message.count}.by(1)
        end
      end

      it 'does not send a message' do
        perform_enqueued_jobs do 
          expect do
            TestDatabaseMailer.ping(contact.email).deliver_later
          end.to change { ActionMailer::Base.deliveries.size }.by(0)
        end
      end

      it 'running daily messages task sends a message' do
        perform_enqueued_jobs do
          expect do
            TestDatabaseMailer.ping(contact.email).deliver_later
            MessageJob.new('daily').perform  
          end.to change { ActionMailer::Base.deliveries.size }.by(1)
        end
      end
    end
  end

end