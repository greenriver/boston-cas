###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CasSeeds::Vouchers do
  let(:csv_file_path) { 'db/vouchers.csv' }
  let(:seeder) { described_class.new }

  before do
    # Create required funding sources that exist in the CSV
    create(:funding_source, name: 'HUD: CoC - Permanent Supportive Housing')
  end

  describe '#run!' do
    context 'when importing project-based programs' do
      let(:csv_content) do
        <<~CSV
          Program Name,Subprograms,Funding Source,Housing Subsidy Administrator,Service Provider,Sub-Contractor,Contract Start Date,"Project, Tenant, or Sponsor based?",Site if project-based,# of Units available if project-based,# of Vouchers if not project-based,Services,Rules,Date available
          Test Program,Test SubProgram,HUD: CoC - Permanent Supportive Housing,Test HSA,Test Provider,Test Contractor,2015-01-01,Project-Based,Test Building,3,,Mental Health Services,Must be chronically homeless,
        CSV
      end

      before do
        allow(CSV).to receive(:read).with(
          csv_file_path,
          headers: true,
          encoding: 'bom|utf-8',
        ).and_return(CSV.parse(csv_content, headers: true))
      end

      it 'creates building, sub_program, vouchers, and units' do
        expect do
          seeder.run!
        end.to change(Building, :count).by(1)
          .and change(SubProgram, :count).by(1)
          .and change(Voucher, :count).by(3)
          .and change(Unit, :count).by(3)
      end

      it 'sets elevator_accessible from building default on units' do
        seeder.run!

        created_units = Unit.last(3)
        building = Building.last

        aggregate_failures 'checking elevator_accessible inheritance' do
          created_units.each do |unit|
            expect(unit.elevator_accessible).to eq(building.elevator_accessible_default)
            expect(unit.building).to eq(building)
          end
        end
      end

      it 'creates associated entities correctly' do
        seeder.run!

        building = Building.last
        sub_program = SubProgram.last
        program = Program.last

        aggregate_failures 'checking associations' do
          expect(building.name).to eq('Test Building')
          expect(sub_program.name).to eq('Test SubProgram')
          expect(sub_program.program).to eq(program)
          expect(sub_program.program_type).to eq('Project-Based')
          expect(sub_program.building).to eq(building)
          expect(program.name).to eq('Test Program')
        end
      end

      context 'when building has elevator_accessible_default true' do
        let(:csv_content) do
          <<~CSV
            Program Name,Subprograms,Funding Source,Housing Subsidy Administrator,Service Provider,Sub-Contractor,Contract Start Date,"Project, Tenant, or Sponsor based?",Site if project-based,# of Units available if project-based,# of Vouchers if not project-based,Services,Rules,Date available
            Test Program,Test SubProgram,HUD: CoC - Permanent Supportive Housing,Test HSA,Test Provider,Test Contractor,2015-01-01,Project-Based,Accessible Building,2,,Mental Health Services,Must be chronically homeless,
          CSV
        end

        before do
          # Pre-create building with elevator_accessible_default true
          Building.create!(
            name: 'Accessible Building',
            elevator_accessible_default: true,
          )
        end

        it 'creates units with elevator_accessible true' do
          seeder.run!

          created_units = Unit.last(2)
          aggregate_failures 'checking elevator_accessible values' do
            created_units.each do |unit|
              expect(unit.elevator_accessible).to be true
            end
          end
        end
      end

      context 'when unit creation fails validation' do
        before do
          allow(Unit).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
        end

        it 'rolls back the entire transaction' do
          expect do
            seeder.run!
          rescue ActiveRecord::RecordInvalid
            # Expected to raise
          end.to change(Building, :count).by(0)
            .and change(SubProgram, :count).by(0)
            .and change(Voucher, :count).by(0)
        end
      end
    end

    context 'when importing non-project-based programs' do
      let(:csv_content) do
        <<~CSV
          Program Name,Subprograms,Funding Source,Housing Subsidy Administrator,Service Provider,Sub-Contractor,Contract Start Date,"Project, Tenant, or Sponsor based?",Site if project-based,# of Units available if project-based,# of Vouchers if not project-based,Services,Rules,Date available
          Tenant Program,Tenant SubProgram,HUD: CoC - Permanent Supportive Housing,Test HSA,Test Provider,Test Contractor,2015-01-01,Tenant-Based,,,5,Services for elders,Must be aged 50 or older,
        CSV
      end

      before do
        allow(CSV).to receive(:read).with(
          csv_file_path,
          headers: true,
          encoding: 'bom|utf-8',
        ).and_return(CSV.parse(csv_content, headers: true))
      end

      it 'creates vouchers without units or buildings' do
        expect do
          seeder.run!
        end.to change(Voucher, :count).by(5)
          .and change(Unit, :count).by(0)
          .and change(Building, :count).by(0)
      end

      it 'creates sub_program with correct type' do
        seeder.run!

        sub_program = SubProgram.last
        expect(sub_program.program_type).to eq('Tenant-Based')
        expect(sub_program.building).to be_nil
      end
    end

    context 'when CSV has rows without Program Name' do
      let(:csv_content) do
        <<~CSV
          Program Name,Subprograms,Funding Source,Housing Subsidy Administrator,Service Provider,Sub-Contractor,Contract Start Date,"Project, Tenant, or Sponsor based?",Site if project-based,# of Units available if project-based,# of Vouchers if not project-based,Services,Rules,Date available
          Valid Program,Valid SubProgram,HUD: CoC - Permanent Supportive Housing,Test HSA,Test Provider,Test Contractor,2015-01-01,Tenant-Based,,,2,Services,Rules,
          ,,,,,,,,,,,,
          Another Valid Program,Another SubProgram,HUD: CoC - Permanent Supportive Housing,Test HSA,Test Provider,Test Contractor,2015-01-01,Tenant-Based,,,1,Services,Rules,
        CSV
      end

      before do
        allow(CSV).to receive(:read).with(
          csv_file_path,
          headers: true,
          encoding: 'bom|utf-8',
        ).and_return(CSV.parse(csv_content, headers: true))
      end

      it 'skips rows without Program Name' do
        expect do
          seeder.run!
        end.to change(SubProgram, :count).by(2)
          .and change(Voucher, :count).by(3)
      end
    end

    context 'when creating subgrantees and services' do
      let(:csv_content) do
        <<~CSV
          Program Name,Subprograms,Funding Source,Housing Subsidy Administrator,Service Provider,Sub-Contractor,Contract Start Date,"Project, Tenant, or Sponsor based?",Site if project-based,# of Units available if project-based,# of Vouchers if not project-based,Services,Rules,Date available
          Service Program,Service SubProgram,HUD: CoC - Permanent Supportive Housing,HSA Org,Provider Org,Contractor Org,2015-01-01,Tenant-Based,,,1,"Mental Health Services, Case Management",Rules,
        CSV
      end

      before do
        allow(CSV).to receive(:read).with(
          csv_file_path,
          headers: true,
          encoding: 'bom|utf-8',
        ).and_return(CSV.parse(csv_content, headers: true))

        # Create services referenced in CSV
        Service.create!(name: 'Mental Health Services')
        Service.create!(name: 'Case Management')
      end

      it 'creates or finds subgrantees' do
        expect do
          seeder.run!
        end.to change(Subgrantee, :count).by(3)

        aggregate_failures 'checking subgrantee names' do
          expect(Subgrantee.find_by(name: 'HSA Org')).to be_present
          expect(Subgrantee.find_by(name: 'Provider Org')).to be_present
          expect(Subgrantee.find_by(name: 'Contractor Org')).to be_present
        end
      end

      it 'associates services with program' do
        seeder.run!

        program = Program.last
        service_names = program.services.pluck(:name)

        aggregate_failures 'checking service associations' do
          expect(service_names).to include('Mental Health Services')
          expect(service_names).to include('Case Management')
        end
      end
    end
  end
end
