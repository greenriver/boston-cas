###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rules::IncomeMinimum, type: :model do
  describe 'clients_that_fit' do
    let!(:rule) { create :income_minimum }

    let!(:low_income_client) { create :client, first_name: 'Low', income_total_monthly: 500 }
    let!(:medium_income_client) { create :client, first_name: 'Medium', income_total_monthly: 1500 }
    let!(:high_income_client) { create :client, first_name: 'High', income_total_monthly: 2500 }
    let!(:nil_income_client) { create :client, first_name: 'Nil', income_total_monthly: nil }

    let!(:positive) { create :requirement, rule: rule, positive: true, variable: 1000 }
    let!(:negative) { create :requirement, rule: rule, positive: false, variable: 1000 }

    let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
    let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }

    context 'when positive' do
      it 'matches clients with income >= 1000' do
        expect(clients_that_fit.count).to eq(2)
      end
      it 'contains medium income client' do
        expect(clients_that_fit.ids).to include medium_income_client.id
      end
      it 'contains high income client' do
        expect(clients_that_fit.ids).to include high_income_client.id
      end
      it 'does not contain low income client' do
        expect(clients_that_fit.ids).to_not include low_income_client.id
      end
      it 'does not contain nil income client' do
        expect(clients_that_fit.ids).to_not include nil_income_client.id
      end
    end

    context 'when negative' do
      it 'matches clients with income < 1000' do
        expect(clients_that_dont_fit.count).to eq(2)
      end
      it 'contains low income client' do
        expect(clients_that_dont_fit.ids).to include low_income_client.id
      end
      it 'contains nil income client' do
        expect(clients_that_dont_fit.ids).to include nil_income_client.id
      end
      it 'does not contain medium income client' do
        expect(clients_that_dont_fit.ids).to_not include medium_income_client.id
      end
      it 'does not contain high income client' do
        expect(clients_that_dont_fit.ids).to_not include high_income_client.id
      end
    end
  end
end
