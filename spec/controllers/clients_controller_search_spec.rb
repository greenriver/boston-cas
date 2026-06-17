###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClientsController, type: :controller do
  let!(:admin) { create(:user) }
  let!(:admin_role) { create(:admin_role) }
  let!(:client) { create(:client) }
  let!(:alice) { create(:client, first_name: 'Alice', last_name: 'Alpha', available: true, veteran: true, days_homeless_in_last_three_years: 10) }
  let!(:zoe)   { create(:client, first_name: 'Zoe',   last_name: 'Zulu',  available: false, veteran: false, days_homeless_in_last_three_years: 100) }
  let!(:mona)  { create(:client, first_name: 'Mona',  last_name: 'Mike',  available: true, veteran: false, days_homeless_in_last_three_years: 5) }
  let!(:vera)  { create(:client, first_name: 'Vera',  last_name: 'Vane',  available: false, veteran: true, days_homeless_in_last_three_years: 50) }
  let!(:search_query) { create(:client_search_query, created_by: admin) }

  before do
    authenticate admin
    admin.roles << admin_role
  end

  describe 'GET #search' do
    it 'assigns the search query and clients collection' do
      get :search, params: { id: search_query.id }
      expect(assigns(:search_query)).to eq(search_query)
      expect(assigns(:clients)).to respond_to(:each)
    end

    it 'renders the clients index template' do
      get :search, params: { id: search_query.id }
      expect(response).to render_template('clients/index')
    end

    it 'uses the search query parameters' do
      get :search, params: { id: search_query.id }
      expect(assigns(:search_query).query_params).to eq(search_query.params.with_indifferent_access)
    end

    context 'filtering' do
      let!(:blank_query) { create(:client_search_query, created_by: admin, params: {}) }

      it 'filters by availability: unavailable' do
        get :search, params: { id: blank_query.id, availability: 'unavailable' }
        ids = assigns(:clients).pluck(:id)
        expect(ids).to include(zoe.id, vera.id)
        expect(ids).not_to include(alice.id, mona.id)
      end

      it 'filters by veteran status: veteran=1' do
        get :search, params: { id: blank_query.id, veteran: '1' }
        ids = assigns(:clients).pluck(:id)
        expect(ids).to include(alice.id, vera.id)
        expect(ids).not_to include(zoe.id, mona.id)
      end

      it 'filters by both availability and veteran' do
        get :search, params: { id: blank_query.id, availability: 'unavailable', veteran: '1' }
        ids = assigns(:clients).pluck(:id)
        expect(ids).to eq([vera.id])
      end

      it 'filters with a search string (q persisted)' do
        q = create(:client_search_query, created_by: admin, params: { q: 'Ali' })
        get :search, params: { id: q.id }
        ids = assigns(:clients).pluck(:id)
        expect(ids).to include(alice.id)
        expect(ids).not_to include(zoe.id, mona.id, vera.id)
      end

      it 'filters with both q and availability' do
        q = create(:client_search_query, created_by: admin, params: { q: 'Zo' })
        get :search, params: { id: q.id, availability: 'unavailable' }
        ids = assigns(:clients).pluck(:id)
        expect(ids).to eq([zoe.id])
      end
    end

    context 'sorting' do
      let!(:blank_query) { create(:client_search_query, created_by: admin, params: {}) }

      it 'sorts by default (days_homeless_in_last_three_years desc) and exposes the expected title' do
        get :search, params: { id: blank_query.id }
        expect(assigns(:sorted_by)).to eq('Most served in last three years')
        # confirm order by days_homeless_in_last_three_years desc: zoe(100), vera(50), alice(10), mona(5)
        ordered_ids = assigns(:clients).map(&:id)
        expect(ordered_ids.index(zoe.id)).to be < ordered_ids.index(vera.id)
        expect(ordered_ids.index(vera.id)).to be < ordered_ids.index(alice.id)
        expect(ordered_ids.index(alice.id)).to be < ordered_ids.index(mona.id)
      end

      it 'sorts by last name Z-A' do
        get :search, params: { id: blank_query.id, sort: 'last_name', direction: 'desc' }
        last_names = assigns(:clients).map(&:last_name)
        expect(last_names).to start_with('Zulu', 'Vane').or start_with('Zulu')
        expect(last_names).to include('Mike', 'Alpha')
        # Ensure Zulu comes before Mike and Alpha
        expect(last_names.index('Zulu')).to be < last_names.index('Mike')
        expect(last_names.index('Mike')).to be < last_names.index('Alpha')
      end

      it 'sorts with a filter (veteran) applied' do
        get :search, params: { id: blank_query.id, sort: 'last_name', direction: 'desc', veteran: '1' }
        last_names = assigns(:clients).map(&:last_name)
        expect(last_names).to eq(['Zulu', 'Vane', 'Alpha'].select { |ln| ['Vane', 'Alpha'].include?(ln) }.sort.reverse)
        expect(last_names).to eq(['Vane', 'Alpha'])
      end

      it 'sorts with a search (q persisted) applied' do
        q = create(:client_search_query, created_by: admin, params: { q: 'a' })
        get :search, params: { id: q.id, sort: 'last_name', direction: 'desc' }
        last_names = assigns(:clients).map(&:last_name)
        # Names containing 'a' in first or last: Alpha, Vane, Mike (Mona), Zulu (Zoe) may or may not match depending on text_search rules.
        # Ensure order still respects last_name desc among results present
        expect(last_names).to eq(last_names.sort.reverse)
      end
    end
  end
end
