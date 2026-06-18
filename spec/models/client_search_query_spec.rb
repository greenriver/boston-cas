###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClientSearchQuery, type: :model do
  let(:user) { create(:user) }
  let(:valid_params) { { q: 'john doe' } }
  let(:client_params) do
    {
      q: 'search term',
      client: {
        first_name: 'John',
        last_name: 'Doe',
        dob: '1990-01-01',
        ssn: '123-45-6789',
      },
    }
  end

  describe 'associations' do
    it { should belong_to(:created_by).class_name('User') }
  end

  describe 'validations' do
    let(:search_query) { build(:client_search_query, params: valid_params) }

    it 'validates allowed parameters' do
      search_query.params = { invalid_param: 'test' }
      search_query.validate_params
      expect(search_query.errors[:params]).to include('contains invalid parameters: invalid_param')
    end

    it 'validates allowed client parameters' do
      search_query.params = { client: { invalid_param: 'test' } }
      search_query.validate_params
      expect(search_query.errors[:params]).to include('contains invalid client parameters: invalid_param')
    end

    it 'validates string lengths' do
      long_string = 'a' * 101
      search_query.params = { q: long_string }
      search_query.validate_params
      expect(search_query.errors[:params]).to include('q is too long (max 100 characters)')
    end

    it 'allows valid parameters' do
      search_query.params = valid_params
      search_query.validate_params
      expect(search_query.errors[:params]).to be_empty
    end
  end

  describe '.permit_params' do
    let(:params) { ActionController::Parameters.new(client_params) }

    it 'permits allowed parameters' do
      permitted = ClientSearchQuery.permit_params(params)
      expect(permitted).to include('q')
      expect(permitted[:client]).to include('first_name', 'last_name', 'dob', 'ssn')
    end

    it 'filters out disallowed parameters' do
      params[:invalid_param] = 'test'
      params[:client][:invalid_client_param] = 'test'
      permitted = ClientSearchQuery.permit_params(params)
      expect(permitted).not_to have_key('invalid_param')
      expect(permitted[:client]).not_to have_key('invalid_client_param')
    end
  end

  describe '.normalize_params' do
    it 'strips whitespace from strings' do
      params = { q: '  test  ' }
      normalized = ClientSearchQuery.normalize_params(params)
      expect(normalized[:q]).to eq('test')
    end

    it 'removes blank values' do
      params = { q: 'test', empty: '' }
      normalized = ClientSearchQuery.normalize_params(params)
      expect(normalized).not_to have_key(:empty)
    end

    it 'sorts keys' do
      params = { z: 'last', a: 'first' }
      normalized = ClientSearchQuery.normalize_params(params)
      expect(normalized.keys).to eq([:a, :z])
    end
  end

  describe '.generate_fingerprint' do
    it 'generates consistent fingerprints for same params' do
      params = { q: 'test' }
      fingerprint1 = ClientSearchQuery.generate_fingerprint(params)
      fingerprint2 = ClientSearchQuery.generate_fingerprint(params)
      expect(fingerprint1).to eq(fingerprint2)
    end

    it 'generates different fingerprints for different params' do
      params1 = { q: 'test1' }
      params2 = { q: 'test2' }
      fingerprint1 = ClientSearchQuery.generate_fingerprint(params1)
      fingerprint2 = ClientSearchQuery.generate_fingerprint(params2)
      expect(fingerprint1).not_to eq(fingerprint2)
    end
  end

  describe '.find_or_create_by_params' do
    it 'creates a new search query for valid params' do
      expect do
        ClientSearchQuery.find_or_create_by_params(valid_params, user: user)
      end.to change(ClientSearchQuery, :count).by(1)
    end

    it 'returns existing search query for duplicate params' do
      search_query = ClientSearchQuery.find_or_create_by_params(valid_params, user: user)
      duplicate = ClientSearchQuery.find_or_create_by_params(valid_params, user: user)
      expect(duplicate.id).to eq(search_query.id)
    end

    it 'returns invalid instance for invalid params' do
      invalid_params = { invalid_param: 'test' }
      result = ClientSearchQuery.find_or_create_by_params(invalid_params, user: user)
      expect(result.errors).to be_present
    end
  end

  describe '#query_params' do
    it 'returns params with indifferent access' do
      search_query = build(:client_search_query, params: { q: 'test' })
      query_params = search_query.query_params
      expect(query_params[:q]).to eq('test')
      expect(query_params['q']).to eq('test')
    end
  end
end
