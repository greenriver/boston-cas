###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BuildingsController, type: :controller do
  let(:user)       { create(:user) }
  let(:admin_role) { create(:admin_role) }

  before do
    authenticate(user)
    user.roles << admin_role
  end

  describe 'POST #create' do
    it 'creates the building and redirects to it' do
      expect do
        post :create, params: { building: { name: 'New Building' } }
      end.to change(Building, :count).by(1)
      expect(response).to redirect_to(building_path(Building.last))
    end

    context 'when a variable-requiring rule is submitted with a blank variable' do
      let!(:variable_rule) { create(:bedroom_exact) }

      it 're-renders the form with errors instead of persisting or raising' do
        expect do
          post :create, params: {
            building: {
              name: 'New Building',
              requirements_attributes: [
                { 'rule_id' => variable_rule.id.to_s, 'positive' => 'true', 'variable' => '' },
              ],
            },
          }
        end.not_to change(Building, :count)

        expect(Requirement.count).to eq(0)
        expect(response).to render_template(:new)
        expect(assigns(:building).errors).to be_present
      end
    end
  end
end
