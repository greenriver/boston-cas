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
          'units' => [{ 'building_id' => building.id, 'unit_number' => '1A' }],
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

    it 'is invalid when units is empty for a physical unit submission' do
      vs = described_class.new(
        status: 'awaiting_approval',
        draft_data: {
          'program_id' => program.id,
          'sub_program_id' => sub_program.id,
          'is_voucher' => false,
          'units' => [],
        },
      )
      expect(vs).not_to be_valid
      expect(vs.errors[:units]).to be_present
    end

    it 'is invalid when a physical unit is missing a building' do
      vs = described_class.new(
        status: 'awaiting_approval',
        draft_data: {
          'program_id' => program.id,
          'sub_program_id' => sub_program.id,
          'is_voucher' => false,
          'units' => [{ 'building_id' => '', 'unit_number' => '1A' }],
        },
      )
      expect(vs).not_to be_valid
      expect(vs.errors[:units]).to be_present
    end

    it 'is invalid when a physical unit is missing a unit number' do
      vs = described_class.new(
        status: 'awaiting_approval',
        draft_data: {
          'program_id' => program.id,
          'sub_program_id' => sub_program.id,
          'is_voucher' => false,
          'units' => [{ 'building_id' => building.id, 'unit_number' => '' }],
        },
      )
      expect(vs).not_to be_valid
      expect(vs.errors[:units]).to be_present
    end

    it 'is invalid when one of multiple physical units is missing its building or unit number' do
      vs = described_class.new(
        status: 'awaiting_approval',
        draft_data: {
          'program_id' => program.id,
          'sub_program_id' => sub_program.id,
          'is_voucher' => false,
          'units' => [
            { 'building_id' => building.id, 'unit_number' => '1A' },
            { 'building_id' => '', 'unit_number' => '' },
          ],
        },
      )
      expect(vs).not_to be_valid
      expect(vs.errors[:units]).to be_present
    end

    it 'is invalid when a requirement uses a variable-requiring rule but the variable is blank' do
      variable_rule = create(:bedroom_exact)
      vs = described_class.new(
        status: 'awaiting_approval',
        draft_data: {
          'program_id' => program.id,
          'sub_program_id' => sub_program.id,
          'is_voucher' => false,
          'units' => [
            {
              'building_id' => building.id, 'unit_number' => '1A',
              'requirements' => [
                { 'rule_id' => variable_rule.id.to_s, 'positive' => 'true', 'variable' => '' },
              ]
            },
          ],
        },
      )
      expect(vs).not_to be_valid
      expect(vs.errors[:units]).to be_present
    end

    it 'is valid when a variable-requiring rule has its variable set' do
      variable_rule = create(:bedroom_exact)
      vs = described_class.new(
        status: 'awaiting_approval',
        draft_data: {
          'program_id' => program.id,
          'sub_program_id' => sub_program.id,
          'is_voucher' => false,
          'units' => [
            {
              'building_id' => building.id, 'unit_number' => '1A',
              'requirements' => [
                { 'rule_id' => variable_rule.id.to_s, 'positive' => 'true', 'variable' => '2' },
              ]
            },
          ],
        },
      )
      expect(vs).to be_valid
    end

    it 'ignores a blank variable for a rule that does not require one' do
      non_variable_rule = create(:homeless)
      vs = described_class.new(
        status: 'awaiting_approval',
        draft_data: {
          'program_id' => program.id,
          'sub_program_id' => sub_program.id,
          'is_voucher' => false,
          'units' => [
            {
              'building_id' => building.id, 'unit_number' => '1A',
              'requirements' => [
                { 'rule_id' => non_variable_rule.id.to_s, 'positive' => 'true', 'variable' => '' },
              ]
            },
          ],
        },
      )
      expect(vs).to be_valid
    end

    it 'is invalid when a voucher requirement uses a variable-requiring rule with a blank variable' do
      variable_rule = create(:bedroom_exact)
      vs = described_class.new(
        status: 'awaiting_approval',
        draft_data: {
          'program_id' => program.id,
          'sub_program_id' => tenant_based_sub_program.id,
          'is_voucher' => true,
          'units' => [
            {
              'name' => 'Voucher #1',
              'requirements' => [
                { 'rule_id' => variable_rule.id.to_s, 'positive' => 'true', 'variable' => '' },
              ],
            },
          ],
        },
      )
      expect(vs).not_to be_valid
      expect(vs.errors[:units]).to be_present
    end

    it 'is valid with a named voucher' do
      vs = described_class.new(
        status: 'awaiting_approval',
        draft_data: {
          'program_id' => program.id,
          'sub_program_id' => tenant_based_sub_program.id,
          'is_voucher' => true,
          'units' => [{ 'name' => 'Section 8 #1234' }],
        },
      )
      expect(vs).to be_valid
    end

    it 'is invalid when a voucher unit has a blank name' do
      vs = described_class.new(
        status: 'awaiting_approval',
        draft_data: {
          'program_id' => program.id,
          'sub_program_id' => tenant_based_sub_program.id,
          'is_voucher' => true,
          'units' => [{ 'name' => '' }],
        },
      )
      expect(vs).not_to be_valid
      expect(vs.errors[:units]).to be_present
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

  describe '.derive_route' do
    it 'returns a non-blank string for any program with a match_route' do
      expect(described_class.derive_route(sub_program)).to be_present
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
    it 'returns the building name, unit number, and full address for each physical unit' do
      elm = create(:building, name: 'Elm Apartments', address: '123 Main St', city: 'Boston', state: 'MA', zip_code: '02101')
      oak = create(:building, name: 'Oak House', address: '456 Oak Ave', city: 'Cambridge', state: 'MA', zip_code: '02139')
      vs = described_class.new(draft_data: {
                                 'is_voucher' => false,
                                 'units' => [
                                   { 'building_id' => elm.id, 'unit_number' => '1A' },
                                   { 'building_id' => oak.id, 'unit_number' => '2B' },
                                 ],
                               })
      expect(vs.site_display).to eq(
        [
          'Elm Apartments, Unit 1A, 123 Main St, Boston, MA 02101',
          'Oak House, Unit 2B, 456 Oak Ave, Cambridge, MA 02139',
        ],
      )
    end

    it 'falls back to a placeholder when the building can no longer be found' do
      vs = described_class.new(draft_data: {
                                 'is_voucher' => false,
                                 'units' => [{ 'building_id' => 0, 'unit_number' => '1A' }],
                               })
      expect(vs.site_display).to eq(['—'])
    end

    it 'returns an empty array for vouchers' do
      vs = described_class.new(draft_data: { 'is_voucher' => true, 'units' => [{ 'name' => 'V-1' }] })
      expect(vs.site_display).to eq(['N/A'])
    end
  end

  describe '#required_document_names' do
    it 'stores and retrieves an array of document name strings' do
      vs = described_class.new(
        draft_data: { 'required_document_names' => ['Photo ID', 'Lease Agreement'] },
      )
      expect(vs.required_document_names).to eq(['Photo ID', 'Lease Agreement'])
    end

    it 'returns nil when not set' do
      vs = described_class.new(draft_data: {})
      expect(vs.required_document_names).to be_nil
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

      context 'for a Tenant-Based (voucher) submission' do
        let!(:rule) { create(:homeless) }
        let(:voucher_submission) do
          create(
            :vacancy_submission,
            :voucher,
            status: 'awaiting_approval',
            the_program: program,
            the_sub_program: tenant_based_sub_program,
          )
        end

        before do
          voucher_submission.units = [
            {
              'name' => 'Voucher #1',
              'date_ready' => '2026-08-15',
              'requirements' => [
                { 'rule_id' => rule.id.to_s, 'positive' => 'true', 'variable' => '' },
              ],
            },
          ]
          voucher_submission.save!
        end

        it 'creates one Voucher per unit entry with no unit assigned and unavailable' do
          expect { voucher_submission.approve!(user: user) }.to change(Voucher, :count).by(1)
          voucher = Voucher.last
          expect(voucher.sub_program).to eq(tenant_based_sub_program)
          expect(voucher.unit_id).to be_nil
          expect(voucher.available).to eq(false)
        end

        it 'persists the created voucher_id back onto the submission, with no unit_id' do
          voucher_submission.approve!(user: user)
          unit_hash = voucher_submission.reload.units.first
          expect(unit_hash['voucher_id']).to eq(Voucher.last.id)
          expect(unit_hash['unit_id']).to be_nil
        end

        it 'creates an unpublished Opportunity for the voucher' do
          voucher_submission.approve!(user: user)
          opportunity = Voucher.last.opportunity
          expect(opportunity).to be_present
          expect(opportunity.available).to eq(false)
          expect(opportunity.available_candidate).to eq(false)
        end

        it 'attaches requirements directly to the Voucher' do
          voucher_submission.approve!(user: user)
          voucher = Voucher.last
          expect(voucher.requirements.count).to eq(1)
          requirement = voucher.requirements.last
          expect(requirement.rule_id).to eq(rule.id)
          expect(requirement.positive).to eq(true)
        end

        it 'sets date_available from date_ready' do
          voucher_submission.approve!(user: user)
          expect(Voucher.last.date_available).to eq(Date.parse('2026-08-15'))
        end

        it 'defaults date_available to Date.current when date_ready is blank' do
          voucher_submission.units = [{ 'name' => 'Voucher #1' }]
          voucher_submission.save!
          voucher_submission.approve!(user: user)
          expect(Voucher.last.date_available).to eq(Date.current)
        end

        it 'raises ActiveRecord::RecordInvalid and rolls back when sub_program_id does not resolve' do
          voucher_submission.units = [{ 'name' => 'Voucher #1' }]
          voucher_submission.sub_program_id = 0
          voucher_submission.save!(validate: false)

          expect { voucher_submission.approve!(user: user) }.to raise_error(ActiveRecord::RecordInvalid)
          expect(voucher_submission.reload.status).to eq('awaiting_approval')
        end
      end

      context 'for a Project-Based (physical unit) submission' do
        let!(:rule) { create(:homeless) }
        let!(:wheelchair_rule) { create(:wheelchair_accessible) }
        let!(:sro_ok_rule) { create(:sro_ok) }
        let!(:bedroom_exact_rule) { create(:bedroom_exact) }
        let!(:age_greater_than_fifty_rule) { create(:age_greater_than_fifty) }
        let!(:age_greater_than_fifty_five_rule) { create(:age_greater_than_fifty_five) }
        let!(:age_greater_than_sixty_rule) { create(:age_greater_than_sixty) }
        let(:physical_submission) do
          create(
            :vacancy_submission,
            status: 'awaiting_approval',
            the_program: program,
            the_sub_program: sub_program,
          )
        end

        before do
          physical_submission.units = [
            {
              'building_id' => building.id,
              'unit_number' => '1A',
              'notes' => 'Newly renovated',
              'accessibility' => ['Elevator to unit'],
              'requirements' => [
                { 'rule_id' => rule.id.to_s, 'positive' => 'true', 'variable' => '' },
              ],
            },
          ]
          physical_submission.save!
        end

        it 'does not create a new Building' do
          expect { physical_submission.approve!(user: user) }.not_to change(Building, :count)
        end

        it 'creates a Unit on the submitted existing Building, associated to the new Voucher' do
          expect { physical_submission.approve!(user: user) }.to change(Unit, :count).by(1)
          unit = Unit.last
          expect(unit.building).to eq(building)
          voucher = Voucher.last
          expect(voucher.unit).to eq(unit)
        end

        it 'persists the created unit_id and voucher_id back onto the submission' do
          physical_submission.approve!(user: user)
          unit_hash = physical_submission.reload.units.first
          expect(unit_hash['unit_id']).to eq(Unit.last.id)
          expect(unit_hash['voucher_id']).to eq(Voucher.last.id)
        end

        it 'creates a Unit on the submitted building for each unit entry, without creating buildings' do
          physical_submission.units = [
            { 'building_id' => building.id, 'unit_number' => '1A' },
            { 'building_id' => building.id, 'unit_number' => '1B' },
          ]
          physical_submission.save!

          expect { physical_submission.approve!(user: user) }.to change(Unit, :count).by(2).
            and change(Building, :count).by(0)
          expect(Unit.last(2).map(&:building).uniq).to eq([building])
        end

        it 'raises RecordInvalid and rolls back when the submitted building cannot be found' do
          physical_submission.units = [{ 'building_id' => 0, 'unit_number' => '1A' }]
          physical_submission.save!

          expect { physical_submission.approve!(user: user) }.to raise_error(ActiveRecord::RecordInvalid)
          expect(physical_submission.reload.status).to eq('awaiting_approval')
          expect(Unit.count).to eq(0)
          expect(Voucher.count).to eq(0)
        end

        it 'uses unit_number for Unit#name' do
          physical_submission.approve!(user: user)
          expect(Unit.last.name).to eq('1A')
        end

        it 'sets Unit#available to true' do
          physical_submission.approve!(user: user)
          expect(Unit.last.available).to eq(true)
        end

        it 'sets Unit#elevator_accessible to true when accessibility includes Elevator to unit' do
          physical_submission.approve!(user: user)
          expect(Unit.last.elevator_accessible).to eq(true)
        end

        it 'sets Unit#elevator_accessible to true when accessibility includes Ground floor unit' do
          physical_submission.units = [
            {
              'building_id' => building.id,
              'unit_number' => '1A',
              'accessibility' => ['Ground floor unit'],
            },
          ]
          physical_submission.save!

          physical_submission.approve!(user: user)
          expect(Unit.last.elevator_accessible).to eq(true)
        end

        it 'sets Unit#elevator_accessible to false when accessibility does not include an elevator option' do
          physical_submission.units = [
            {
              'building_id' => building.id,
              'unit_number' => '1A',
              'accessibility' => ['Wheelchair accessible unit'],
            },
          ]
          physical_submission.save!

          physical_submission.approve!(user: user)
          expect(Unit.last.elevator_accessible).to eq(false)
        end

        it 'sets Unit#notes from the submitted per-unit notes' do
          physical_submission.approve!(user: user)
          expect(Unit.last.notes).to eq('Newly renovated')
        end

        it 'attaches unit-level requirements to the Unit, not the Voucher' do
          physical_submission.approve!(user: user)
          unit = Unit.last
          voucher = Voucher.last

          requirement = unit.requirements.find_by(rule_id: rule.id)
          expect(requirement).to be_present
          expect(requirement.positive).to eq(true)
          expect(requirement.requirer).to eq(unit)

          expect(voucher.requirements.count).to eq(0)
        end

        it 'creates an exclusionary Requirement when positive is submitted as false' do
          physical_submission.units = [
            {
              'building_id' => building.id,
              'unit_number' => '1A',
              'requirements' => [
                { 'rule_id' => rule.id.to_s, 'positive' => 'false', 'variable' => '' },
              ],
            },
          ]
          physical_submission.save!

          physical_submission.approve!(user: user)
          requirement = Unit.last.requirements.find_by(rule_id: rule.id)
          expect(requirement.positive).to eq(false)
        end

        it 'defaults a Requirement to positive when positive is omitted' do
          physical_submission.units = [
            {
              'building_id' => building.id,
              'unit_number' => '1A',
              'requirements' => [
                { 'rule_id' => rule.id.to_s, 'variable' => '' },
              ],
            },
          ]
          physical_submission.save!

          physical_submission.approve!(user: user)
          requirement = Unit.last.requirements.find_by(rule_id: rule.id)
          expect(requirement.positive).to eq(true)
        end

        it 'creates exactly one Rules::Wheelchair Requirement when both wheelchair accessibility options are selected' do
          physical_submission.units = [
            {
              'building_id' => building.id,
              'unit_number' => '1A',
              'accessibility' => ['Wheelchair accessible unit', 'Wheelchair accessible building'],
            },
          ]
          physical_submission.save!

          physical_submission.approve!(user: user)
          unit = Unit.last
          wheelchair_requirements = unit.requirements.select { |r| r.rule.type == wheelchair_rule.type }
          expect(wheelchair_requirements.size).to eq(1)
          expect(wheelchair_requirements.first.positive).to eq(true)
        end

        it 'does not create a Requirement for elevator/ground-floor accessibility (captured by Unit#elevator_accessible)' do
          # Rules::Elevator is intentionally not a seeded rule — elevator/ground-floor
          # accessibility is represented by the Unit#elevator_accessible boolean, which
          # matching consumes directly. Approval must not depend on a Rules::Elevator rule.
          physical_submission.units = [
            {
              'building_id' => building.id,
              'unit_number' => '1A',
              'accessibility' => ['Elevator to unit', 'Ground floor unit'],
            },
          ]
          physical_submission.save!

          expect { physical_submission.approve!(user: user) }.not_to raise_error
          unit = Unit.last
          expect(unit.elevator_accessible).to eq(true)
          expect(unit.requirements).to be_empty
        end

        context 'bedrooms' do
          {
            'SRO' => { rule: :sro_ok_rule, variable: nil },
            'Studio' => { rule: :bedroom_exact_rule, variable: '1' },
            'One bedroom' => { rule: :bedroom_exact_rule, variable: '1' },
            'Two bedrooms' => { rule: :bedroom_exact_rule, variable: '2' },
            'Three or more bedrooms' => { rule: :bedroom_exact_rule, variable: '3' },
          }.each do |bedroom_option, expectation|
            it "creates the expected Requirement for bedrooms: #{bedroom_option}" do
              physical_submission.units = [
                {
                  'building_id' => building.id,
                  'unit_number' => '1A',
                  'bedrooms' => bedroom_option,
                },
              ]
              physical_submission.save!

              physical_submission.approve!(user: user)
              unit = Unit.last
              expect(unit.requirements.count).to eq(1)
              requirement = unit.requirements.last
              expect(requirement.rule.type).to eq(send(expectation[:rule]).type)
              expect(requirement.positive).to eq(true)
              expect(requirement.variable).to eq(expectation[:variable])
            end
          end
        end

        context 'age_limit' do
          {
            '50+' => :age_greater_than_fifty_rule,
            '55+' => :age_greater_than_fifty_five_rule,
            '60+' => :age_greater_than_sixty_rule,
          }.each do |age_limit_option, rule_let|
            it "creates the expected Requirement for age_limit: #{age_limit_option}" do
              physical_submission.units = [
                {
                  'building_id' => building.id,
                  'unit_number' => '1A',
                  'age_limit' => age_limit_option,
                },
              ]
              physical_submission.save!

              physical_submission.approve!(user: user)
              unit = Unit.last
              expect(unit.requirements.count).to eq(1)
              requirement = unit.requirements.last
              expect(requirement.rule.type).to eq(send(rule_let).type)
              expect(requirement.positive).to eq(true)
            end
          end

          it 'creates no Requirement when age_limit is N/A' do
            physical_submission.units = [
              {
                'building_id' => building.id,
                'unit_number' => '1A',
                'age_limit' => 'N/A',
              },
            ]
            physical_submission.save!

            physical_submission.approve!(user: user)
            expect(Unit.last.requirements.count).to eq(0)
          end

          it 'creates no Requirement when age_limit is blank' do
            physical_submission.units = [
              {
                'building_id' => building.id,
                'unit_number' => '1A',
              },
            ]
            physical_submission.save!

            physical_submission.approve!(user: user)
            expect(Unit.last.requirements.count).to eq(0)
          end
        end

        context 'shared spaces, amenities, attributes, and media links' do
          it 'creates a HousingAttribute with include_value: false for each shared space' do
            physical_submission.units = [
              {
                'building_id' => building.id,
                'unit_number' => '1A',
                'shared_spaces' => ['Laundry room', 'Common kitchen'],
              },
            ]
            physical_submission.save!

            physical_submission.approve!(user: user)
            unit = Unit.last
            attributes = unit.housing_attributes.without_value
            expect(attributes.pluck(:name)).to contain_exactly('Laundry room', 'Common kitchen')
            expect(attributes.pluck(:include_value)).to all(eq(false))
          end

          it 'creates a HousingAttribute with include_value: false for each amenity' do
            physical_submission.units = [
              {
                'building_id' => building.id,
                'unit_number' => '1A',
                'amenities' => ['Dishwasher', 'Air conditioning'],
              },
            ]
            physical_submission.save!

            physical_submission.approve!(user: user)
            unit = Unit.last
            attributes = unit.housing_attributes.without_value
            expect(attributes.pluck(:name)).to contain_exactly('Dishwasher', 'Air conditioning')
            expect(attributes.pluck(:include_value)).to all(eq(false))
          end

          it 'creates a HousingAttribute with include_value: true for each name/value attribute, skipping blank names' do
            physical_submission.units = [
              {
                'building_id' => building.id,
                'unit_number' => '1A',
                'attributes' => [
                  { 'name' => 'Heat', 'value' => 'Gas' },
                  { 'name' => '', 'value' => 'Should be skipped' },
                ],
              },
            ]
            physical_submission.save!

            physical_submission.approve!(user: user)
            unit = Unit.last
            attributes = unit.housing_attributes.with_value
            expect(attributes.count).to eq(1)
            expect(attributes.first.name).to eq('Heat')
            expect(attributes.first.value).to eq('Gas')
            expect(attributes.first.include_value).to eq(true)
          end

          it 'skips attributes with a blank value instead of raising' do
            physical_submission.units = [
              {
                'building_id' => building.id,
                'unit_number' => '1A',
                'attributes' => [
                  { 'name' => 'Heat', 'value' => 'Gas' },
                  { 'name' => 'Should be skipped', 'value' => '' },
                ],
              },
            ]
            physical_submission.save!

            expect { physical_submission.approve!(user: user) }.not_to raise_error
            unit = Unit.last
            attributes = unit.housing_attributes.with_value
            expect(attributes.count).to eq(1)
            expect(attributes.first.name).to eq('Heat')
          end

          it 'creates a HousingMediaLink for each media link, skipping blank urls, defaulting blank labels to Photo' do
            physical_submission.units = [
              {
                'building_id' => building.id,
                'unit_number' => '1A',
                'media_links' => [
                  { 'url' => 'https://example.com/photo.jpg', 'label' => 'Kitchen' },
                  { 'url' => 'https://example.com/photo2.jpg', 'label' => '' },
                  { 'url' => '', 'label' => 'Should be skipped' },
                ],
              },
            ]
            physical_submission.save!

            physical_submission.approve!(user: user)
            unit = Unit.last
            media_links = unit.housing_media_links
            expect(media_links.count).to eq(2)
            expect(media_links.pluck(:url)).to contain_exactly('https://example.com/photo.jpg', 'https://example.com/photo2.jpg')
            kitchen_link = media_links.find_by(url: 'https://example.com/photo.jpg')
            expect(kitchen_link.label).to eq('Kitchen')
            defaulted_link = media_links.find_by(url: 'https://example.com/photo2.jpg')
            expect(defaulted_link.label).to eq('Photo')
          end
        end
      end

      context 'failure modes (atomicity and error surfacing)' do
        let(:failing_submission) do
          create(
            :vacancy_submission,
            status: 'awaiting_approval',
            the_program: program,
            the_sub_program: sub_program,
          )
        end

        it 'raises RecordInvalid and rolls back everything when a unit ready date is unparseable' do
          failing_submission.units = [
            {
              'building_id' => building.id,
              'unit_number' => '1A',
              'date_ready' => 'not-a-date',
            },
          ]
          failing_submission.save!

          expect { failing_submission.approve!(user: user) }.to raise_error(ActiveRecord::RecordInvalid)
          expect(failing_submission.reload.status).to eq('awaiting_approval')
          expect(Voucher.count).to eq(0)
          expect(Unit.count).to eq(0)
          expect(Requirement.count).to eq(0)
        end

        it 'raises RecordInvalid and rolls back everything when a required Rule is not configured' do
          # Simulate a misconfigured environment: 'Wheelchair accessible unit' maps to
          # Rules::Wheelchair, so remove that seeded rule to force the find_rule! guard.
          Rule.where(type: 'Rules::Wheelchair').destroy_all
          failing_submission.units = [
            {
              'building_id' => building.id,
              'unit_number' => '1A',
              'accessibility' => ['Wheelchair accessible unit'],
            },
          ]
          failing_submission.save!

          expect { failing_submission.approve!(user: user) }.to raise_error(ActiveRecord::RecordInvalid)
          expect(failing_submission.reload.status).to eq('awaiting_approval')
          expect(Voucher.count).to eq(0)
          expect(Unit.count).to eq(0)
        end
      end

      context 'weighting rules' do
        # The :program factory uses MatchRoutes::Default.first, so a WeightingRule on
        # that route applies to the submission's sub-program (match_route is through the
        # program). This mirrors how opportunities_controller/vouchers_controller apply
        # weighting rules when they create vouchers.
        let(:route) { MatchRoutes::Default.first }

        context 'when the route has an active weighting rule' do
          let!(:weighting_rule_rule) { create(:homeless) }
          let!(:weighting_rule) do
            wr = create(:weighting_rule, route: route)
            Requirement.create!(requirer: wr, rule: weighting_rule_rule)
            wr
          end

          let(:physical_submission) do
            create(
              :vacancy_submission,
              status: 'awaiting_approval',
              the_program: program,
              the_sub_program: sub_program,
            )
          end

          it 'copies the weighting rule requirements onto the created Voucher' do
            physical_submission.approve!(user: user)
            expect(Voucher.last.requirements.map(&:rule_id)).to include(weighting_rule_rule.id)
          end

          it 'increments the weighting rule applied_to counter once per created voucher' do
            expect { physical_submission.approve!(user: user) }.to change { weighting_rule.reload.applied_to }.by(1)
          end

          it 'applies weighting rules to Tenant-Based (voucher-only) submissions too' do
            voucher_submission = create(
              :vacancy_submission,
              :voucher,
              status: 'awaiting_approval',
              the_program: program,
              the_sub_program: tenant_based_sub_program,
            )

            voucher_submission.approve!(user: user)
            expect(Voucher.last.requirements.map(&:rule_id)).to include(weighting_rule_rule.id)
            expect(weighting_rule.reload.applied_to).to eq(1)
          end

          it 'applies weighting rules once per voucher for multi-unit submissions' do
            physical_submission.units = [
              { 'building_id' => building.id, 'unit_number' => '1A' },
              { 'building_id' => building.id, 'unit_number' => '1B' },
            ]
            physical_submission.save!

            expect { physical_submission.approve!(user: user) }.to change { weighting_rule.reload.applied_to }.by(2)
            expect(Voucher.last(2).map { |v| v.requirements.map(&:rule_id) }).to all(include(weighting_rule_rule.id))
          end

          it 'does not apply weighting rules when the sub-program has them disabled' do
            sub_program.update!(weighting_rules_active: false)

            expect { physical_submission.approve!(user: user) }.not_to(change { weighting_rule.reload.applied_to })
            expect(Voucher.last.requirements.map(&:rule_id)).not_to include(weighting_rule_rule.id)
          end
        end

        context 'when the route has no weighting rules' do
          let(:physical_submission) do
            create(
              :vacancy_submission,
              status: 'awaiting_approval',
              the_program: program,
              the_sub_program: sub_program,
            )
          end

          it 'approves without error and creates the voucher' do
            expect { physical_submission.approve!(user: user) }.to change(Voucher, :count).by(1)
          end
        end
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

      it 'returns a submission whose units predate the building requirement without validating them' do
        legacy = create(:vacancy_submission, status: 'awaiting_approval')
        legacy.units = [{ 'street' => '123 Main St', 'city' => 'Boston', 'state' => 'MA', 'zip' => '02101' }]
        legacy.save!(validate: false)

        expect do
          legacy.return_for_changes!(body: 'Please pick a building.', user: user)
        end.to change { legacy.reload.status }.to('return_changes_requested')
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
