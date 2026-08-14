###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

# Regression net for the Rails 7.2 -> 8.1 upgrade (audit hotspot).
#
# Rails 8 sets a global `Regexp.timeout` (1 second by default).
# https://guides.rubyonrails.org/configuring.html#default-values-for-target-version-8-0
# These are the only free-text regexes in the app that run against user-supplied strings:
#   - NonHmisClientsHelper::PHONE_NUMBER_REGEX (validated in
#     PathwaysVersionFourCalculations)
#   - the "^Email:/^Phone:/^Address:" matches in
#     Client#structured_rrh_assessment_contact_info
#
# These specs characterize current 7.2 behavior (correct parse) and assert the
# matches complete well under the 1s timeout even on adversarial-length input,
# so a regression under the new default surfaces here rather than in production.
RSpec.describe 'Free-text regex regression', type: :model do
  describe 'NonHmisClientsHelper::PHONE_NUMBER_REGEX' do
    subject(:regex) { NonHmisClientsHelper::PHONE_NUMBER_REGEX }

    it 'matches representative phone formats' do
      expect('555-123-4567').to match(regex)
      expect('(555) 123-4567').to match(regex)
      expect('5551234567').to match(regex)
    end

    it 'does not match non-phone text' do
      expect('not a phone number').not_to match(regex)
      expect('12345').not_to match(regex)
    end

    it 'completes quickly on adversarial-length input (no catastrophic backtracking)' do
      adversarial = '9' * 100_000
      elapsed = Benchmark.realtime { adversarial.match?(regex) }
      expect(elapsed).to be < 1.0
    end
  end

  describe 'Client#structured_rrh_assessment_contact_info' do
    let(:contact_info) do
      <<~TEXT.strip
        Jane Smith
        Phone: 555-123-4567
        Email: jane@example.com
        Address: 123 Main St, Apt 4
      TEXT
    end

    subject(:parsed) { Client.new(rrh_assessment_contact_info: contact_info).structured_rrh_assessment_contact_info }

    it 'parses the free-text contact block into structured fields' do
      expect(parsed.first_name).to eq('Jane')
      expect(parsed.last_name).to eq('Smith')
      expect(parsed.phone).to eq('555-123-4567')
      expect(parsed.email).to eq('jane@example.com')
      expect(parsed.address).to eq('123 Main St, Apt 4')
    end

    it 'returns nil when the field is blank' do
      expect(Client.new(rrh_assessment_contact_info: nil).structured_rrh_assessment_contact_info).to be_nil
    end

    it 'treats a block with no Email: line as a bare name' do
      result = Client.new(rrh_assessment_contact_info: 'Just A Name').structured_rrh_assessment_contact_info
      expect(result.first_name).to eq('Just A Name')
    end

    it 'completes quickly on adversarial-length input (no catastrophic backtracking)' do
      adversarial = "Jane Smith\nEmail: " + ('a' * 100_000)
      elapsed = Benchmark.realtime do
        Client.new(rrh_assessment_contact_info: adversarial).structured_rrh_assessment_contact_info
      end
      expect(elapsed).to be < 1.0
    end
  end
end
