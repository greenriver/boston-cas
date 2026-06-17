###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NonHmisClient, type: :model do
  describe '.visible_through_user_agency' do
    let!(:user_agency) { create(:agency, name: 'User Agency') }
    let!(:other_agency) { create(:agency, name: 'Other Agency') }

    let!(:user_with_covid_pathways_permission) do
      user = create(:user, agency: user_agency)
      role = create(:role, name: 'covid_viewer', can_view_all_covid_pathways: true)
      user.roles << role
      user
    end

    let!(:user_without_covid_pathways_permission) do
      user = create(:user, agency: user_agency)
      role = create(:role, name: 'no_covid_viewer', can_view_all_covid_pathways: false)
      user.roles << role
      user
    end

    # Clients (using deidentified_client factory as a concrete NonHmisClient)
    let!(:client_user_agency) { create(:deidentified_client, agency: user_agency, first_name: 'CUA') }
    let!(:client_other_agency) { create(:deidentified_client, agency: other_agency, first_name: 'COA') }
    let!(:client_nil_agency) { create(:deidentified_client, agency: nil, first_name: 'CNA') }

    # Assessments
    let!(:client_with_limitable_assessment_user_agency) do
      client = create(:deidentified_client, agency: user_agency, first_name: 'CLAUA')
      create(:non_hmis_assessment, :limitable_pathway, non_hmis_client: client, agency: user_agency)
      client
    end

    let!(:client_with_limitable_assessment_other_agency) do
      client = create(:deidentified_client, agency: other_agency, first_name: 'CLAOA')
      create(:non_hmis_assessment, :limitable_pathway, non_hmis_client: client, agency: other_agency)
      client
    end

    let!(:client_with_non_limitable_assessment_other_agency) do
      client = create(:deidentified_client, agency: other_agency, first_name: 'CNLAOA')
      create(:non_hmis_assessment, :non_limitable_pathway, non_hmis_client: client, agency: other_agency)
      client
    end

    context 'when user has can_view_all_covid_pathways? permission' do
      subject(:scope_results) { described_class.visible_through_user_agency(user_with_covid_pathways_permission) }

      it 'includes clients from user\'s agency' do
        expect(scope_results).to include(client_user_agency)
      end

      it 'includes clients with nil agency' do
        expect(scope_results).to include(client_nil_agency)
      end

      it 'includes clients with limitable pathway assessments from user\'s agency' do
        expect(scope_results).to include(client_with_limitable_assessment_user_agency)
      end

      it 'includes clients with limitable pathway assessments from other agencies' do
        expect(scope_results).to include(client_with_limitable_assessment_other_agency)
      end

      it 'does not include clients from other agencies without limitable pathways' do
        expect(scope_results).not_to include(client_other_agency)
      end

      it 'does not include clients with non-limitable assessments from other agencies' do
        expect(scope_results).not_to include(client_with_non_limitable_assessment_other_agency)
      end

      it 'returns a distinct list of clients' do
        # client_with_limitable_assessment_user_agency is visible due to agency AND pathway
        expect(scope_results.where(id: client_with_limitable_assessment_user_agency.id).count).to eq(1)
      end
    end

    context 'when user does not have can_view_all_covid_pathways? permission' do
      subject(:scope_results) { described_class.visible_through_user_agency(user_without_covid_pathways_permission) }

      it 'includes clients from user\'s agency' do
        expect(scope_results).to include(client_user_agency)
      end

      it 'includes clients with nil agency' do
        expect(scope_results).to include(client_nil_agency)
      end

      it 'includes clients with limitable pathway assessments from user\'s agency (due to agency match)' do
        expect(scope_results).to include(client_with_limitable_assessment_user_agency)
      end

      it 'does not include clients from other agencies without limitable pathways' do
        expect(scope_results).not_to include(client_other_agency)
      end

      it 'does not include clients with limitable pathway assessments from other agencies' do
        expect(scope_results).not_to include(client_with_limitable_assessment_other_agency)
      end

      it 'does not include clients with non-limitable assessments from other agencies' do
        expect(scope_results).not_to include(client_with_non_limitable_assessment_other_agency)
      end
    end
  end
end
