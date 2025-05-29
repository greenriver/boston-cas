# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IdentifiedClient, type: :model do
  describe '.visible_to' do
    let!(:user_agency) { create(:agency, name: 'User Agency') }
    let!(:other_agency) { create(:agency, name: 'Other Agency') }

    let!(:user_with_edit_all_role) do
      user = create(:user, agency: user_agency)
      role = create(:role, name: 'editor_of_all', can_edit_all_clients: true)
      user.roles << role
      user
    end

    let!(:user_with_manage_identified_role) do
      user = create(:user, agency: user_agency)
      role = create(:role, name: 'identified_manager', can_edit_all_clients: false, can_manage_all_identified_clients: true)
      user.roles << role
      user
    end

    let!(:user_with_basic_role) do
      user = create(:user, agency: user_agency)
      role = create(:role, name: 'basic_user',
                           can_edit_all_clients: false,
                           can_manage_all_identified_clients: false,
                           can_view_all_covid_pathways: false)
      user.roles << role
      user
    end

    let!(:client_user_agency) { create(:identified_client, agency: user_agency, first_name: 'ClientUserAgency') }
    let!(:client_other_agency) { create(:identified_client, agency: other_agency, first_name: 'ClientOtherAgency') }
    let!(:client_nil_agency) { create(:identified_client, agency: nil, first_name: 'ClientNilAgency') }

    context 'when user has a role with can_edit_all_clients?' do
      it 'returns all identified clients' do
        scope_results = described_class.visible_to(user_with_edit_all_role)
        expect(scope_results).to contain_exactly(client_user_agency, client_other_agency, client_nil_agency)
      end
    end

    context 'when user has a role with can_manage_all_identified_clients?' do
      it 'returns all identified clients' do
        scope_results = described_class.visible_to(user_with_manage_identified_role)
        expect(scope_results).to contain_exactly(client_user_agency, client_other_agency, client_nil_agency)
      end
    end

    context 'when user has a basic role' do
      it 'returns clients from their agency and nil agency only' do
        scope_results = described_class.visible_to(user_with_basic_role)
        expect(scope_results).to contain_exactly(
          client_user_agency,
          client_nil_agency,
        )
        expect(scope_results).not_to include(client_other_agency)
      end
    end
  end
end
