require 'rails_helper'

RSpec.describe Rules::ActiveInCohort, type: :model do
  before { skip "Requires warehouse classes" }

  describe 'clients_that_fit' do
    let!(:cohort_a) { create :cohort_a }
    let!(:cohort_b) { create :cohort_b }

    let!(:rule) { create :active_in_cohort_a }

    let!(:bob) { create :client, first_name: 'Bob', active_cohort_ids: [ cohort_a.id ] }
    let!(:roy) { create :client, first_name: 'Roy', active_cohort_ids: [ cohort_b.id ] }
    let!(:mary) { create :client, first_name: 'Mary', active_cohort_ids: [ cohort_a.id, cohort_b.id ] }
    let!(:sue) { create :client, first_name: 'Sue', active_cohort_ids: nil }

    let!(:positive) { create :requirement, rule: rule, positive: true, variable: cohort_a.id }
    let!(:negative) { create :requirement, rule: rule, positive: false, variable: cohort_a.id }

    let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
    let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }

    context 'when positive' do
      it 'matches 2' do
        expect(clients_that_fit.count).to eq(2)
      end
      it 'contains Bob' do
        expect(clients_that_fit.ids).to include bob.id
      end
      it 'does not contain Roy' do
        expect(clients_that_fit.ids).to_not include roy.id
      end
      it 'contains Mary' do
        expect(clients_that_fit.ids).to include mary.id
      end
      it 'does not contain Sue' do
        expect(clients_that_fit.ids).to_not include sue.id
      end
    end

    context 'when negative' do
      it 'matches 2' do
        expect(clients_that_dont_fit.count).to eq(2)
      end
      it 'does not contain Bob' do
        expect(clients_that_dont_fit.ids).to_not include bob.id
      end
      it 'contains Roy' do
        expect(clients_that_dont_fit.ids).to include roy.id
      end
      it 'does not contain Mary' do
        expect(clients_that_dont_fit.ids).to_not include mary.id
      end
      it 'contains Sue' do
        expect(clients_that_dont_fit.ids).to include sue.id
      end
    end

  end
end