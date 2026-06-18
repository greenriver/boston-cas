###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnitForBuildingController, type: :controller do
  let(:user) { create(:user) }
  let(:admin_role) { create(:admin_role) }
  let(:route) { create(:default_route) }
  let(:program) { create(:program, match_route: route) }
  let(:sub_program) { create(:sub_program, program: program) }

  before do
    authenticate(user)
    user.roles << admin_role
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        unit_for_building: {
          name: 'Test Unit 101',
          available: true,
          building_id: building.id,
        },
        program_id: program.id,
        sub_program_id: sub_program.id,
      }
    end

    context 'when building has elevator_accessible_default true' do
      let(:building) { create(:building, elevator_accessible_default: true) }

      it 'creates unit with elevator_accessible set to true' do
        expect do
          post :create, params: valid_params
        end.to change(Unit, :count).by(1)

        created_unit = Unit.last
        expect(created_unit.elevator_accessible).to be true
      end

      it 'assigns elevator_accessible from building default' do
        post :create, params: valid_params

        created_unit = Unit.last
        aggregate_failures 'checking unit attributes' do
          expect(created_unit.building).to eq(building)
          expect(created_unit.elevator_accessible).to eq(building.elevator_accessible_default)
          expect(created_unit.name).to eq('Test Unit 101')
          expect(created_unit.available).to be true
        end
      end

      it 'redirects to vouchers path on success' do
        post :create, params: valid_params

        expect(response).to redirect_to(
          program_sub_program_vouchers_path(
            program_id: program.id,
            sub_program_id: sub_program.id,
          ),
        )
      end

      it 'sets success flash message' do
        post :create, params: valid_params

        expect(flash[:notice]).to include('was successfully created')
      end
    end

    context 'when building has elevator_accessible_default false' do
      let(:building) { create(:building, elevator_accessible_default: false) }

      it 'creates unit with elevator_accessible set to false' do
        expect do
          post :create, params: valid_params
        end.to change(Unit, :count).by(1)

        created_unit = Unit.last
        expect(created_unit.elevator_accessible).to be false
      end

      it 'assigns elevator_accessible from building default' do
        post :create, params: valid_params

        created_unit = Unit.last
        aggregate_failures 'checking unit attributes' do
          expect(created_unit.building).to eq(building)
          expect(created_unit.elevator_accessible).to eq(building.elevator_accessible_default)
        end
      end
    end

    context 'when explicitly passing elevator_accessible in params' do
      let(:building) { create(:building, elevator_accessible_default: false) }
      let(:params_with_elevator_accessible) do
        valid_params.deep_merge(
          unit_for_building: { elevator_accessible: true },
        )
      end

      it 'overrides with building default regardless of param value' do
        post :create, params: params_with_elevator_accessible

        created_unit = Unit.last
        expect(created_unit.elevator_accessible).to eq(building.elevator_accessible_default)
      end
    end

    context 'when unit creation fails validation' do
      let(:building) { create(:building, elevator_accessible_default: true) }
      let(:invalid_params) do
        {
          unit_for_building: {
            name: '',
            building_id: building.id,
          },
          program_id: program.id,
          sub_program_id: sub_program.id,
        }
      end

      it 'does not create a unit' do
        expect do
          post :create, params: invalid_params
        end.not_to change(Unit, :count)
      end

      it 'sets error flash message' do
        post :create, params: invalid_params

        expect(flash[:error]).to eq('Unable to add unit')
      end
    end
  end

  describe 'GET #new' do
    it 'initializes empty units array' do
      get :new, params: { program_id: program.id, sub_program_id: sub_program.id }

      expect(assigns(:units)).to eq([])
    end

    it 'loads buildings' do
      building1 = create(:building)
      building2 = create(:building)

      get :new, params: { program_id: program.id, sub_program_id: sub_program.id }

      expect(assigns(:buildings)).to match_array([building1, building2])
    end
  end

  describe 'GET #edit' do
    let(:building) { create(:building, elevator_accessible_default: true) }
    let(:unit) { create(:unit, building: building) }

    it 'loads the unit and building' do
      get :edit, params: {
        id: unit.id,
        program_id: program.id,
        sub_program_id: sub_program.id,
      }

      aggregate_failures 'checking assignments' do
        expect(assigns(:unit)).to eq(unit)
        expect(assigns(:building)).to eq(building)
      end
    end
  end

  describe 'PATCH #update' do
    let(:building) { create(:building, elevator_accessible_default: false) }
    let(:unit) { create(:unit, building: building, name: 'Old Name') }
    let(:update_params) do
      {
        id: unit.id,
        unit_for_building: {
          name: 'New Name',
          elevator_accessible: true,
        },
        program_id: program.id,
        sub_program_id: sub_program.id,
      }
    end

    it 'updates the unit attributes' do
      patch :update, params: update_params

      unit.reload
      aggregate_failures 'checking updated attributes' do
        expect(unit.name).to eq('New Name')
        expect(unit.elevator_accessible).to be true
      end
    end

    it 'redirects to vouchers path on success' do
      patch :update, params: update_params

      expect(response).to redirect_to(
        program_sub_program_vouchers_path(
          program_id: program.id,
          sub_program_id: sub_program.id,
        ),
      )
    end

    it 'sets success flash message' do
      patch :update, params: update_params

      expect(flash[:notice]).to include('was successfully updated')
    end
  end
end
