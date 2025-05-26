# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeidentifiedClient, type: :model do
  describe '.visible_to' do
    let!(:user_agency) { create(:agency, name: 'User Agency') }
    let!(:other_agency) { create(:agency, name: 'Other Agency') }

    let!(:user_with_edit_all_role) do
      user = create(:user, agency: user_agency)
      role = create(:role, name: 'editor_of_all', can_edit_all_clients: true)
      user.roles << role
      user
    end

    let!(:user_with_manage_deidentified_role) do
      user = create(:user, agency: user_agency)
      role = create(:role, name: 'deidentified_manager', can_edit_all_clients: false, can_manage_all_deidentified_clients: true)
      user.roles << role
      user
    end

    let!(:user_with_covid_pathways_role) do
      user = create(:user, agency: user_agency)
      role = create(:role, name: 'covid_pathway_viewer',
                           can_edit_all_clients: false,
                           can_manage_all_deidentified_clients: false,
                           can_view_all_covid_pathways: true)
      user.roles << role
      user
    end

    let!(:user_with_basic_role) do
      user = create(:user, agency: user_agency)
      role = create(:role, name: 'basic_user',
                           can_edit_all_clients: false,
                           can_manage_all_deidentified_clients: false,
                           can_view_all_covid_pathways: false)
      user.roles << role
      user
    end

    let!(:client_user_agency) { create(:deidentified_client, agency: user_agency, first_name: 'ClientUserAgency') }
    let!(:client_other_agency) { create(:deidentified_client, agency: other_agency, first_name: 'ClientOtherAgency') }
    let!(:client_nil_agency) { create(:deidentified_client, agency: nil, first_name: 'ClientNilAgency') }

    # For testing visible_through_user_agency indirectly
    let!(:client_covid_pathway_other_agency) do
      client = create(:deidentified_client, agency: other_agency, first_name: 'ClientCovidOtherAgency')
      create(:non_hmis_assessment, :limitable_pathway, non_hmis_client: client, agency: other_agency)
      client
    end

    let!(:client_covid_pathway_user_agency) do
      client = create(:deidentified_client, agency: user_agency, first_name: 'ClientCovidUserAgency')
      create(:non_hmis_assessment, :limitable_pathway, non_hmis_client: client, agency: user_agency)
      client
    end

    context 'when user has a role with can_edit_all_clients?' do
      it 'returns all deidentified clients' do
        scope_results = described_class.visible_to(user_with_edit_all_role)
        expect(scope_results).to contain_exactly(client_user_agency, client_other_agency, client_nil_agency, client_covid_pathway_other_agency, client_covid_pathway_user_agency)
      end
    end

    context 'when user has a role with can_manage_all_deidentified_clients?' do
      it 'returns all deidentified clients' do
        scope_results = described_class.visible_to(user_with_manage_deidentified_role)
        expect(scope_results).to contain_exactly(client_user_agency, client_other_agency, client_nil_agency, client_covid_pathway_other_agency, client_covid_pathway_user_agency)
      end
    end

    context 'when user has basic role and can_view_all_covid_pathways?' do
      # This user can see their own agency's clients, nil agency clients,
      # and any client with a covid pathway assessment.
      it 'returns clients from user agency, nil agency, and those with COVID pathway assessments' do
        scope_results = described_class.visible_to(user_with_covid_pathways_role)
        expect(scope_results).to contain_exactly(
          client_user_agency,
          client_nil_agency,
          client_covid_pathway_user_agency, # Via user_agency AND covid pathway
          client_covid_pathway_other_agency, # Via covid pathway only
        )
        expect(scope_results).not_to include(client_other_agency) # No covid pathway, other agency
      end
    end

    context 'when user has basic role and cannot_view_all_covid_pathways?' do
      # This user can only see their own agency's clients and nil agency clients.
      it 'returns clients from user agency and nil agency only' do
        scope_results = described_class.visible_to(user_with_basic_role)
        expect(scope_results).to contain_exactly(
          client_user_agency,
          client_nil_agency,
          client_covid_pathway_user_agency, # Via user_agency (covid pathway is irrelevant here for visibility scope)
        )
        expect(scope_results).not_to include(client_other_agency)
        expect(scope_results).not_to include(client_covid_pathway_other_agency)
      end
    end
  end
end
