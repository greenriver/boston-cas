###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cas::UpdateVoucherAvailability do
  let(:user) { create(:user) }
  let(:program) { create(:program) }
  let(:tenant_based_sub_program) { create(:sub_program, program: program, program_type: 'Tenant-Based') }

  describe '#run!' do
    context 'composing with VacancySubmissions::Approval' do
      let(:voucher_submission) do
        create(
          :vacancy_submission,
          :voucher,
          status: 'awaiting_approval',
          the_program: program,
          the_sub_program: tenant_based_sub_program,
        )
      end

      context 'when date_ready is in the past' do
        before do
          voucher_submission.units = [{ 'name' => 'Voucher #1', 'date_ready' => 1.day.ago.to_date.iso8601 }]
          voucher_submission.save!
          voucher_submission.approve!(user: user)
        end

        it 'publishes the Voucher and its Opportunity in the same run!' do
          described_class.new.run!

          voucher = Voucher.last
          expect(voucher.available).to eq(true)
          expect(voucher.date_available).to be_nil

          opportunity = voucher.opportunity
          expect(opportunity.available).to eq(true)
          expect(opportunity.available_candidate).to eq(true)
        end
      end

      context 'when date_ready is in the future' do
        before do
          voucher_submission.units = [{ 'name' => 'Voucher #1', 'date_ready' => 1.day.from_now.to_date.iso8601 }]
          voucher_submission.save!
          voucher_submission.approve!(user: user)
        end

        it 'leaves the Voucher and its Opportunity unpublished' do
          described_class.new.run!

          voucher = Voucher.last
          expect(voucher.available).to eq(false)
          expect(voucher.date_available).to eq(1.day.from_now.to_date)

          opportunity = voucher.opportunity
          expect(opportunity.available).to eq(false)
          expect(opportunity.available_candidate).to eq(false)
        end
      end
    end

    context 'branch: available voucher with a past date_available whose opportunity lags' do
      it 'clears date_available and publishes the lagging Opportunity' do
        voucher = create(:voucher, available: true, date_available: 1.day.ago.to_date)
        opportunity = create(:opportunity, voucher: voucher, available: false, available_candidate: false)

        described_class.new.run!

        expect(voucher.reload.date_available).to be_nil
        expect(opportunity.reload.available).to eq(true)
        expect(opportunity.available_candidate).to eq(true)
      end
    end

    context 'branch: available voucher with no date_available whose opportunity lags' do
      it 'publishes the lagging Opportunity' do
        voucher = create(:voucher, available: true, date_available: nil)
        opportunity = create(:opportunity, voucher: voucher, available: false, available_candidate: false)

        described_class.new.run!

        expect(opportunity.reload.available).to eq(true)
        expect(opportunity.available_candidate).to eq(true)
      end
    end
  end
end
