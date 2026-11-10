###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
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

  describe 'authorization' do
    context 'when user lacks can_view_opportunities and can_add_vacancies' do
      let(:unprivileged_user) { create(:user) }

      before do
        authenticate(unprivileged_user)
      end

      it 'redirects from new' do
        get :new
        expect(response).to redirect_to(root_path)
      end

      it 'prevents creating opportunities' do
        sub_program = create(:sub_program, program: program, program_type: 'Sponsor-Based')
        expect do
          post :create, params: { opportunity: { program: sub_program.id.to_s, units: '1' } }
        end.not_to change(Opportunity, :count)
        expect(Voucher.count).to eq(0)
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when user can only view opportunities' do
      let(:viewer) { create(:user) }

      before do
        viewer.roles << create(:role, name: 'viewer', can_view_opportunities: true, can_view_programs: true)
        authenticate(viewer)
      end

      it 'does not create vacancies' do
        sub_program = create(:sub_program, program: program)
        expect do
          post :create, params: { opportunity: { program: sub_program.id.to_s, units: '1' } }
        end.not_to change(Voucher, :count)
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when user can add vacancies for assigned programs only' do
      let(:assigned_user) { create(:user) }
      let(:other_program) { create(:program, name: 'Other Agency Program', match_route: route) }
      let(:own_sub_program) { create(:sub_program, program: program) }

      before do
        assigned_user.roles << create(:role, name: 'assigned_vacancy', can_add_vacancies: true, can_view_assigned_programs: true)
        EntityViewPermission.create!(entity: program, agency: assigned_user.agency)
        authenticate(assigned_user)
      end

      it 'does not create vouchers in a sub-program outside the user programs' do
        other_sub_program = create(:sub_program, program: other_program)
        expect do
          post :create, params: { opportunity: { program: other_sub_program.id.to_s, units: '1' } }
        end.not_to change(Voucher, :count)
        expect(response).to render_template(:new)
      end

      it 'creates vouchers in a sub-program in the user programs' do
        expect do
          post :create, params: { opportunity: { program: own_sub_program.id.to_s, units: '1' } }
        end.to change(Voucher, :count).by(1)
      end

      it 'does not create units in a building outside the user sub-programs' do
        own_building = create(:building)
        project_sub_program = create(:sub_program, program: program, program_type: 'Project-Based', building: own_building)
        foreign_building = create(:building)
        create(:sub_program, program: other_program, program_type: 'Project-Based', building: foreign_building)
        expect do
          post :create, params: { opportunity: { program: project_sub_program.id.to_s, building: foreign_building.id.to_s, units: '1' } }
        end.not_to change { [Unit.count, Voucher.count] }
        expect(response).to render_template(:new)
      end
    end

    context 'when user has can_add_vacancies' do
      let(:vacancy_role) { create(:role, name: 'vacancy_manager', can_add_vacancies: true, can_view_programs: true) }
      let(:vacancy_user) { create(:user) }

      before do
        vacancy_user.roles << vacancy_role
        authenticate(vacancy_user)
      end

      it 'allows access to new' do
        get :new
        expect(response).to have_http_status(:success)
      end
    end
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
