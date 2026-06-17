###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CleanupClientSearchQueriesTask do
  let(:task) { described_class.new }
  let(:retention_period) { described_class::RETENTION_PERIOD }

  describe '#perform' do
    let!(:recent_query) { create(:client_search_query, :with_client_params, updated_at: 1.year.ago) }
    let!(:old_query) { create(:client_search_query, updated_at: 3.years.ago) }

    it 'deletes queries older than retention period' do
      expect do
        task.perform
      end.to change(ClientSearchQuery, :count).by(-1)

      expect(ClientSearchQuery.find_by(id: recent_query.id)).to be_present
      expect(ClientSearchQuery.find_by(id: old_query.id)).to be_nil
    end

    it 'uses advisory lock' do
      expect(ApplicationRecord).to receive(:with_advisory_lock).with('CleanupClientSearchQueriesTask', timeout_seconds: 0)
      task.perform
    end

    it 'runs in a transaction' do
      expect(ClientSearchQuery).to receive(:transaction)
      task.perform
    end
  end
end
