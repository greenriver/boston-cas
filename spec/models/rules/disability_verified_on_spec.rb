require 'rails_helper'

RSpec.describe Rules::VerifiedDisability, type: :model do

  let!(:verified_disability) { create :rules_verified_disability }
  let!(:verified_clients) { create_list :client, 4, disability_verified_on: Date.yesterday }
  let!(:unverified_clients) { create_list :client, 2, disability_verified_on: nil }

  let!(:positive) { create :requirement, rule: verified_disability, positive: true }
  let!(:negative) { create :requirement, rule: verified_disability, positive: false }
  let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
  let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }

  describe 'clients_that_fit' do

    context 'when positive' do
      it 'matches verified clients' do
        expect( clients_that_fit.count ).to eq 4
      end
      it 'contains verified clients' do
        expect( clients_that_fit.ids ).to include *verified_clients.map(&:id)
      end
      it 'does not contain unverified clients' do
        expect( clients_that_fit.ids ).to_not include *unverified_clients.map(&:id)
      end
    end
    context 'when negative' do
      it 'matches unverified clients' do
        expect( clients_that_dont_fit.count ).to eq 2
      end
      it 'contains unverified clients' do
        expect( clients_that_dont_fit.ids ).to include *unverified_clients.map(&:id)
      end
      it 'does not contain verified clients' do
        expect( clients_that_dont_fit.ids ).to_not include *verified_clients.map(&:id)
      end
    end
  end
end
