# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reporting::Decisions, type: :model do
  describe '.has_reason' do
    let!(:health_and_safety_decline) do
      create(:reporting_decision, decline_reason: 'Health and Safety')
    end

    let!(:health_and_safety_cancel) do
      create(:reporting_decision, administrative_cancel_reason: 'Health and Safety')
    end

    let!(:cori_decline) do
      create(:reporting_decision, decline_reason: 'CORI')
    end

    let!(:other_exact_decline) do
      create(:reporting_decision, decline_reason: 'Other')
    end

    let!(:other_custom_decline) do
      create(:reporting_decision, decline_reason: 'Other: Family emergency')
    end

    let!(:other_exact_cancel) do
      create(:reporting_decision, administrative_cancel_reason: 'Other')
    end

    let!(:other_custom_cancel) do
      create(
        :reporting_decision,
        administrative_cancel_reason: 'Other: Program no longer available',
      )
    end

    let!(:no_reason) do
      create(:reporting_decision)
    end

    context 'with standard reasons' do
      it 'finds records with matching decline_reason' do
        results = described_class.has_reason('Health and Safety')
        expect(results).to include(health_and_safety_decline)
        expect(results).not_to include(cori_decline)
        expect(results).not_to include(no_reason)
      end

      it 'finds records with matching administrative_cancel_reason' do
        results = described_class.has_reason('Health and Safety')
        expect(results).to include(health_and_safety_cancel)
      end

      it 'finds records with either decline_reason or administrative_cancel_reason' do
        results = described_class.has_reason('Health and Safety')
        expect(results.count).to eq(2)
        expect(results).to include(health_and_safety_decline, health_and_safety_cancel)
      end

      it 'does not match partial strings' do
        results = described_class.has_reason('CORI')
        expect(results).to include(cori_decline)
        expect(results).not_to include(health_and_safety_decline)
      end
    end

    context 'with "Other" reason' do
      it 'finds exact "Other" in decline_reason' do
        results = described_class.has_reason('Other')
        expect(results).to include(other_exact_decline)
      end

      it 'finds "Other: custom text" in decline_reason' do
        results = described_class.has_reason('Other')
        expect(results).to include(other_custom_decline)
      end

      it 'finds exact "Other" in administrative_cancel_reason' do
        results = described_class.has_reason('Other')
        expect(results).to include(other_exact_cancel)
      end

      it 'finds "Other: custom text" in administrative_cancel_reason' do
        results = described_class.has_reason('Other')
        expect(results).to include(other_custom_cancel)
      end

      it 'finds all "Other" permutations' do
        results = described_class.has_reason('Other')
        expect(results.count).to eq(4)
        expect(results).to include(
          other_exact_decline,
          other_custom_decline,
          other_exact_cancel,
          other_custom_cancel,
        )
      end

      it 'does not find standard reasons when searching for "Other"' do
        results = described_class.has_reason('Other')
        expect(results).not_to include(health_and_safety_decline)
        expect(results).not_to include(health_and_safety_cancel)
        expect(results).not_to include(cori_decline)
        expect(results).not_to include(no_reason)
      end
    end

    context 'with no matches' do
      it 'returns empty result for non-existent reason' do
        results = described_class.has_reason('Non-existent Reason')
        expect(results.count).to eq(0)
      end
    end
  end
end
