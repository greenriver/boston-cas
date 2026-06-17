###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Voucher, type: :model do
  # Regression coverage for the paper_trail 16 → 17 major upgrade.
  # Voucher#available_at walks the version chain via paper_trail.previous_version.
  # If the gem's API changed between major versions this method would silently
  # return nil or raise, breaking availability reporting.
  describe '#available_at' do
    around do |example|
      # PaperTrail is disabled globally for performance; enable it for these specs.
      PaperTrail.enabled = true
      example.run
      PaperTrail.enabled = false
    end

    context 'when the voucher was created as available' do
      it 'returns the creation timestamp' do
        voucher = nil
        freeze_time = 2.days.ago
        travel_to(freeze_time) do
          voucher = create(:voucher, available: true)
        end
        expect(voucher.available_at).to be_within(1.second).of(freeze_time)
      end
    end

    context 'when the voucher was created unavailable and later made available' do
      it 'returns the timestamp when it became available, not when it was created' do
        voucher = create(:voucher, available: false)

        became_available_at = 1.day.ago
        travel_to(became_available_at) do
          voucher.update!(available: true)
        end

        expect(voucher.available_at).to be_within(1.second).of(became_available_at)
      end
    end

    context 'when the voucher has never been available' do
      it 'returns nil' do
        voucher = create(:voucher, available: false)
        expect(voucher.available_at).to be_nil
      end
    end

    context 'when the voucher became available, then unavailable, then available again' do
      it 'returns the timestamp of the most recent transition to available' do
        first_available_at = 3.days.ago
        voucher = nil
        travel_to(first_available_at) { voucher = create(:voucher, available: true) }
        travel_to(2.days.ago) { voucher.update!(available: false) }

        second_available_at = 1.day.ago
        travel_to(second_available_at) { voucher.update!(available: true) }

        expect(voucher.available_at).to be_within(1.second).of(second_available_at)
      end
    end
  end
end
