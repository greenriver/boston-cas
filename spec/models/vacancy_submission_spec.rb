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
        draft_data: { 'program_id' => program.id, 'sub_program_id' => sub_program.id,
                      'is_voucher' => false, 'unit_address_street' => '123 Main St',
                      'unit_address_city' => 'Boston', 'unit_address_state' => 'MA',
                      'unit_address_zip' => '02101' },
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
      expect(vs.errors[:base]).to include('Program is required')
    end

    it 'is invalid when sub_program_id missing' do
      vs = described_class.new(status: 'awaiting_approval', draft_data: { 'program_id' => program.id })
      expect(vs).not_to be_valid
      expect(vs.errors[:base]).to include('Sub-program is required')
    end

    it 'requires address fields for physical units' do
      vs = described_class.new(
        status: 'awaiting_approval',
        draft_data: { 'program_id' => program.id, 'sub_program_id' => sub_program.id, 'is_voucher' => false },
      )
      expect(vs).not_to be_valid
      expect(vs.errors[:base]).to include('Street address is required')
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
