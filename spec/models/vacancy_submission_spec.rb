###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VacancySubmission, type: :model do
  let(:program) { create(:program) }
  let(:building) { create(:building) }
  let(:sub_program) { create(:sub_program, program: program, program_type: 'Project-Based', building: building) }
  let(:tenant_based_sub_program) { create(:sub_program, program: program, program_type: 'Tenant-Based') }

  describe 'validations' do
    it 'is valid with required fields' do
      vs = described_class.new(
        status: 'awaiting_approval',
        draft_data: {
          'program_id' => program.id,
          'sub_program_id' => sub_program.id,
          'is_voucher' => false,
          'unit_address_street' => '123 Main St',
          'unit_address_city' => 'Boston',
          'unit_address_state' => 'MA',
          'unit_address_zip' => '02101',
        },
      )
      expect(vs).to be_valid
    end

    it 'is invalid with an unknown status' do
      vs = described_class.new(status: 'invalid_status', draft_data: {})
      expect(vs).not_to be_valid
      expect(vs.errors[:status]).to be_present
    end

    it 'is invalid when program_id missing' do
      vs = described_class.new(status: 'awaiting_approval', draft_data: { 'sub_program_id' => sub_program.id })
      expect(vs).not_to be_valid
      expect(vs.errors[:program_id]).to include('can\'t be blank')
    end

    it 'is invalid when sub_program_id missing' do
      vs = described_class.new(status: 'awaiting_approval', draft_data: { 'program_id' => program.id })
      expect(vs).not_to be_valid
      expect(vs.errors[:sub_program_id]).to include('can\'t be blank')
    end

    it 'requires address fields for physical units' do
      vs = described_class.new(
        status: 'awaiting_approval',
        draft_data: { 'program_id' => program.id, 'sub_program_id' => sub_program.id, 'is_voucher' => false },
      )
      expect(vs).not_to be_valid
      expect(vs.errors[:unit_address_street]).to include('can\'t be blank')
    end

    it 'does not require address fields for voucher units' do
      vs = described_class.new(
        status: 'awaiting_approval',
        draft_data: { 'program_id' => program.id, 'sub_program_id' => tenant_based_sub_program.id, 'is_voucher' => true },
      )
      expect(vs).to be_valid
    end
  end

  describe '.derive_is_voucher' do
    it 'returns true for Tenant-Based sub-programs' do
      expect(described_class.derive_is_voucher(tenant_based_sub_program)).to be true
    end

    it 'returns false for Project-Based sub-programs' do
      expect(described_class.derive_is_voucher(sub_program)).to be false
    end
  end

  describe '.derive_resource_type' do
    it 'returns a non-blank string for any program with a match_route' do
      expect(described_class.derive_resource_type(program)).to be_present
    end
  end

  describe 'JSONB accessors' do
    describe '#program_id' do
      it 'casts a string value to integer' do
        vs = described_class.new(draft_data: { 'program_id' => '42' })
        expect(vs.program_id).to eq(42)
      end

      it 'returns nil when not set' do
        vs = described_class.new(draft_data: {})
        expect(vs.program_id).to be_nil
      end
    end

    describe '#sub_program_id' do
      it 'casts a string value to integer' do
        vs = described_class.new(draft_data: { 'sub_program_id' => '7' })
        expect(vs.sub_program_id).to eq(7)
      end

      it 'returns nil when not set' do
        vs = described_class.new(draft_data: {})
        expect(vs.sub_program_id).to be_nil
      end
    end

    describe '#voucher?' do
      it 'returns true when is_voucher is true' do
        vs = described_class.new(draft_data: { 'is_voucher' => true })
        expect(vs.voucher?).to be true
      end

      it 'returns false when is_voucher is false' do
        vs = described_class.new(draft_data: { 'is_voucher' => false })
        expect(vs.voucher?).to be false
      end
    end
  end

  describe '#site_display' do
    it 'returns formatted address for physical units' do
      vs = described_class.new(draft_data: {
                                 'is_voucher' => false,
                                 'unit_address_street' => '123 Main St',
                                 'unit_address_city' => 'Boston',
                                 'unit_address_state' => 'MA',
                                 'unit_address_zip' => '02101',
                               })
      expect(vs.site_display).to eq('123 Main St, Boston, MA, 02101')
    end

    it 'returns em dash for vouchers' do
      vs = described_class.new(draft_data: { 'is_voucher' => true })
      expect(vs.site_display).to eq('—')
    end
  end

  describe '#voucher_type_display' do
    it 'returns Physical Unit when not a voucher' do
      vs = described_class.new(draft_data: { 'is_voucher' => false })
      expect(vs.voucher_type_display).to eq('Physical Unit')
    end

    it 'returns Voucher when is_voucher is true' do
      vs = described_class.new(draft_data: { 'is_voucher' => true })
      expect(vs.voucher_type_display).to eq('Voucher')
    end
  end

  describe '.filtered' do
    let!(:awaiting) { create(:vacancy_submission, status: 'awaiting_approval') }
    let!(:changes) { create(:vacancy_submission, status: 'return_changes_requested') }
    let!(:active) { create(:vacancy_submission, status: 'active') }

    it 'returns queue records by default' do
      result = described_class.filtered(search: nil, status_filter: 'queue')
      expect(result).to include(awaiting, changes)
      expect(result).not_to include(active)
    end

    it 'returns all records for all filter' do
      result = described_class.filtered(search: nil, status_filter: 'all')
      expect(result).to include(awaiting, changes, active)
    end

    it 'returns only the specified status' do
      result = described_class.filtered(search: nil, status_filter: 'active')
      expect(result).to contain_exactly(active)
    end
  end

  describe 'state guard methods' do
    it '#approvable? is true when awaiting_approval' do
      vs = build(:vacancy_submission, status: 'awaiting_approval')
      expect(vs.approvable?).to be true
    end

    it '#approvable? is true when return_changes_requested' do
      vs = build(:vacancy_submission, status: 'return_changes_requested')
      expect(vs.approvable?).to be true
    end

    it '#approvable? is false when active' do
      vs = build(:vacancy_submission, :active)
      expect(vs.approvable?).to be false
    end

    it '#returnable? is true when awaiting_approval' do
      vs = build(:vacancy_submission, status: 'awaiting_approval')
      expect(vs.returnable?).to be true
    end

    it '#returnable? is true when return_changes_requested' do
      vs = build(:vacancy_submission, status: 'return_changes_requested')
      expect(vs.returnable?).to be true
    end

    it '#returnable? is false when active' do
      vs = build(:vacancy_submission, :active)
      expect(vs.returnable?).to be false
    end

    it '#resubmittable? is true only when return_changes_requested' do
      vs = build(:vacancy_submission, :changes_requested)
      expect(vs.resubmittable?).to be true
    end

    it '#resubmittable? is false when awaiting_approval' do
      vs = build(:vacancy_submission, status: 'awaiting_approval')
      expect(vs.resubmittable?).to be false
    end

    it '#resubmittable? is false when active' do
      vs = build(:vacancy_submission, :active)
      expect(vs.resubmittable?).to be false
    end
  end

  describe 'state transition methods' do
    let(:user) { create(:user) }

    describe '#approve!' do
      let(:submission) { create(:vacancy_submission, status: 'awaiting_approval') }

      it 'transitions status to active' do
        expect { submission.approve!(user: user) }.to change { submission.reload.status }.to('active')
      end

      it 'creates a status_change note' do
        expect { submission.approve!(user: user) }.to change(VacancySubmissionNote, :count).by(1)
        expect(VacancySubmissionNote.last.note_type).to eq('status_change')
      end
    end

    describe '#return_for_changes!' do
      let(:submission) { create(:vacancy_submission, status: 'awaiting_approval') }

      it 'transitions status to return_changes_requested' do
        expect do
          submission.return_for_changes!(body: 'Fix the address.', user: user)
        end.to change { submission.reload.status }.to('return_changes_requested')
      end

      it 'creates a reviewer_note and a status_change note' do
        expect do
          submission.return_for_changes!(body: 'Fix it.', user: user)
        end.to change(VacancySubmissionNote, :count).by(2)
        types = VacancySubmissionNote.last(2).map(&:note_type)
        expect(types).to include('reviewer_note', 'status_change')
      end
    end

    describe '#resubmit!' do
      let(:submission) { create(:vacancy_submission, :changes_requested) }

      it 'transitions status to awaiting_approval' do
        expect { submission.resubmit!(user: user) }.to change { submission.reload.status }.to('awaiting_approval')
      end

      it 'creates a status_change note' do
        expect { submission.resubmit!(user: user) }.to change(VacancySubmissionNote, :count).by(1)
      end
    end
  end

  describe 'associations' do
    it 'has many vacancy_submission_notes' do
      vs = create(:vacancy_submission)
      note = create(:vacancy_submission_note, vacancy_submission: vs)
      expect(vs.vacancy_submission_notes).to include(note)
    end

    it 'destroys notes when submission is destroyed' do
      vs = create(:vacancy_submission)
      create(:vacancy_submission_note, vacancy_submission: vs)
      expect { vs.destroy }.to change(VacancySubmissionNote, :count).by(-1)
    end
  end
end
