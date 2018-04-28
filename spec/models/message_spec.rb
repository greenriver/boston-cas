require 'rails_helper'
include ActiveJob::TestHelper
RSpec.describe Message, type: :model do
  let!(:contact) { create :contact, email: "noreply@greenriver.com"}

  describe 'Sending a message with deliver_now' do
    original_message_count = Message.count
    it 'creates a message' do 
      TestMailer.ping(contact.email).deliver_now
      expect(Message.count).to eq(original_message_count + 1)
    end

    it 'sends a message' do
      expect do
        TestMailer.ping(contact.email).deliver_now
      end.to change { ActionMailer::Base.deliveries.size }.by(1)
    end
  end

  describe 'Sending a message with deliver_later' do
    it 'enqueues a job' do 
      expect {
        TestMailer.ping(contact.email).deliver_later
      }.to have_enqueued_job.on_queue('mailers')
      # expect(Message.count).to eq(original_message_count + 1)
    end
    original_message_count = Message.count
    it 'creates a message' do 
      original_message_count = Message.count
      perform_enqueued_jobs do 
        TestMailer.ping(contact.email).deliver_later
        expect(Message.count).to eq(original_message_count + 1)
      end
    end

    it 'sends a message' do
      expect do
        perform_enqueued_jobs do 
          TestMailer.ping(contact.email).deliver_later
        end.to change { ActionMailer::Base.deliveries.size }.by(1)
      end
    end
  end

end