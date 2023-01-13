require 'rails_helper'

RSpec.describe Rules::HasFileTags, type: :model do
  describe 'clients_that_fit' do
    let!(:rule) { create :has_file_tags }

    let!(:bob) { create :client, first_name: 'Bob', file_tags: { 'A' => '2020-01-01' } }
    let!(:roy) { create :client, first_name: 'Roy', file_tags: { 'B' => '2020-01-01' } }
    let!(:mary) { create :client, first_name: 'Mary', file_tags: { 'A' => '2020-01-01', 'B' => '2020-01-01' } }
    let!(:sue) { create :client, first_name: 'Sue', file_tags: nil }

    let!(:positive) { create :requirement, rule: rule, positive: true, variable: 'A,B' }
    let!(:negative) { create :requirement, rule: rule, positive: false, variable: 'A' }

    let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
    let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }

    context 'when positive' do
      it 'matches 1' do
        expect(clients_that_fit.count).to eq(1)
      end
      it 'contains Mary' do
        expect(clients_that_fit.ids).to include mary.id
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
