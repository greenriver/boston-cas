###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeidentifiedClientsController, type: :controller do
  let!(:admin) { create(:user) }
  let!(:admin_role) { create(:admin_role) }
  let!(:agency_a) { admin.agency || create(:agency, name: 'Alpha Agency') }
  let!(:agency_z) { create(:agency, name: 'Zulu Agency') }
  let!(:d1) do
    c = create(:deidentified_client, client_identifier: 'A001', available: true, agency: agency_a)
    NonHmisAssessment.create!(type: 'DeidentifiedClientAssessment', non_hmis_client_id: c.id, entry_date: Date.current)
    c
  end
  let!(:d2) do
    c = create(:deidentified_client, client_identifier: 'Z999', available: false, agency: agency_z)
    NonHmisAssessment.create!(type: 'DeidentifiedClientAssessment', non_hmis_client_id: c.id, entry_date: Date.current)
    c
  end
  let!(:d3) do
    c = create(:deidentified_client, client_identifier: 'M555', available: false, agency: agency_a)
    NonHmisAssessment.create!(type: 'DeidentifiedClientAssessment', non_hmis_client_id: c.id, entry_date: Date.current)
    c
  end
  let!(:search_with_q) { create(:client_search_query, created_by: admin, params: { q: 'A00' }) }
  let!(:search_query) { create(:client_search_query, created_by: admin) }

  before do
    authenticate admin
    admin_role.update(can_enter_deidentified_clients: true, can_manage_deidentified_clients: true)
    admin.roles << admin_role
    # Ensure visibility scope does not exclude our seeded records
    allow(controller).to receive(:client_source).and_return(DeidentifiedClient)
    allow(controller).to receive(:search_scope).and_return(DeidentifiedClient.where(id: [d1.id, d2.id, d3.id]))
  end

  describe 'GET #search' do
    it 'assigns the search query and clients collection' do
      get :search, params: { id: search_query.id }
      expect(assigns(:search_query)).to eq(search_query)
      expect(assigns(:non_hmis_clients)).to respond_to(:each)
    end

    it 'uses the search query parameters' do
      get :search, params: { id: search_query.id }
      expect(assigns(:search_query).query_params).to eq(search_query.params.with_indifferent_access)
    end

    it 'renders the deidentified_clients index template' do
      get :search, params: { id: search_query.id }
      expect(response).to render_template('deidentified_clients/index')
    end

    context 'filtering' do
      it 'filters by availability: available=1' do
        get :search, params: { id: search_with_q.id, available: 'true' }
        ids = assigns(:non_hmis_clients).pluck(:id)
        expect(ids).to include(d1.id)
        expect(ids).not_to include(d2.id, d3.id)
      end

      it 'filters by agency' do
        get :search, params: { id: search_with_q.id, agency: agency_a.name }
        ids = assigns(:non_hmis_clients).pluck(:id)
        expect(ids).to include(d1.id)
        expect(ids).not_to include(d2.id)
      end

      it 'filters with a search string (persisted q)' do
        get :search, params: { id: search_with_q.id }
        ids = assigns(:non_hmis_clients).pluck(:id)
        expect(ids).to include(d1.id)
        expect(ids).not_to include(d2.id, d3.id)
      end
    end

    context 'sorting' do
      it 'sorts by default sort option (assessment date desc if applicable or client_identifier asc fallback)' do
        get :search, params: { id: search_query.id }
        expect(assigns(:sorted_by)).to be_present
      end

      it 'sorts by Client Identifier Z-A' do
        get :search, params: { id: search_query.id, sort: 'client_identifier', direction: 'desc' }
        ids = assigns(:non_hmis_clients).map(&:client_identifier)
        expect(ids).to eq(ids.sort.reverse)
      end

      it 'sorts by Agency Z-A with a filter applied' do
        NonHmisClient.where(id: d1.id).update_all(agency_id: agency_a.id)
        NonHmisClient.where(id: d2.id).update_all(agency_id: agency_z.id)
        get :search, params: { id: search_query.id, sort: 'agencies.name', direction: 'desc', available: 'false' }
        agencies = assigns(:non_hmis_clients).joins(:agency).pluck('agencies.name')
        expect(agencies).to eq(agencies.sort.reverse)
      end
    end
  end
end
