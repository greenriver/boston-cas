###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rules::EverCurrentlyFleeing, type: :model do
  describe 'clients_that_fit' do
    let!(:rule) { create :ever_currently_fleeing }

    let!(:fleeing_client) { create :client, currently_fleeing: true }
    let!(:non_fleeing_client) { create :client, currently_fleeing: false }

    let!(:positive) { create :requirement, rule: rule, positive: true }
    let!(:negative) { create :requirement, rule: rule, positive: false }

    let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
    let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }

    context 'when positive' do
      it 'matches 1' do
        expect(clients_that_fit.count).to eq(1)
      end
      it 'contains fleeing client' do
        expect(clients_that_fit.ids).to include fleeing_client.id
      end
      it 'does not contain non-fleeing client' do
        expect(clients_that_fit.ids).to_not include non_fleeing_client.id
      end
    end

    context 'when negative' do
      it 'matches 1' do
        expect(clients_that_dont_fit.count).to eq(1)
      end
      it 'does not contain fleeing client' do
        expect(clients_that_dont_fit.ids).to_not include fleeing_client.id
      end
      it 'contains non-fleeing client' do
        expect(clients_that_dont_fit.ids).to include non_fleeing_client.id
      end
    end
  end
end
