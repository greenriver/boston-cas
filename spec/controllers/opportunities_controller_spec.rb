###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OpportunitiesController, type: :controller do
  let(:user) { create(:user) }
  let(:admin_role) { create(:admin_role) }
  let(:route) { create(:default_route) }
  let(:program) { create(:program, match_route: route) }

  before do
    authenticate(user)
    user.roles << admin_role
  end

  describe 'POST #create' do
    context 'when creating project-based units' do
      let(:building) { create(:building, elevator_accessible_default: building_default) }
      let(:sub_program) { create(:sub_program, program: program, program_type: 'Project-Based', building: building) }
      let(:valid_params) do
        {
          opportunity: {
            program: sub_program.id.to_s,
            building: building.id.to_s,
            units: '3',
          },
        }
      end

      context 'when building has elevator_accessible_default true' do
        let(:building_default) { true }

        it 'creates units with elevator_accessible set to true' do
          expect do
            post :create, params: valid_params
          end.to change(Unit, :count).by(3)

          created_units = Unit.last(3)
          aggregate_failures 'checking elevator_accessible values' do
            created_units.each do |unit|
              expect(unit.elevator_accessible).to be true
            end
          end
        end

        it 'creates vouchers and opportunities' do
          expect do
            post :create, params: valid_params
          end.to change(Voucher, :count).by(3).and change(Opportunity, :count).by(3)
        end
      end

      context 'when building has elevator_accessible_default false' do
        let(:building_default) { false }

        it 'creates units with elevator_accessible set to false' do
          expect do
            post :create, params: valid_params
          end.to change(Unit, :count).by(3)

          created_units = Unit.last(3)
          aggregate_failures 'checking elevator_accessible values' do
            created_units.each do |unit|
              expect(unit.elevator_accessible).to be false
            end
          end
        end
      end

      context 'when unit creation fails validation' do
        let(:building_default) { false }

        before do
          allow(Unit).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
        end

        it 'raises an error due to create! instead of create' do
          expect do
            post :create, params: valid_params
          end.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end

    context 'when creating non-project-based vouchers' do
      let(:sub_program) { create(:sub_program, program: program, program_type: 'Sponsor-Based') }
      let(:valid_params) do
        {
          opportunity: {
            program: sub_program.id.to_s,
            units: '2',
          },
        }
      end

      it 'creates vouchers without units' do
        expect do
          post :create, params: valid_params
        end.to change(Voucher, :count).by(2).and change(Unit, :count).by(0)
      end

      it 'creates opportunities' do
        expect do
          post :create, params: valid_params
        end.to change(Opportunity, :count).by(2)
      end
    end
  end
end
