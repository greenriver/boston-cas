require 'rails_helper'

RSpec.describe Rules::ActiveInCohort, type: :model do
  describe 'clients_that_fit' do
    let!(:tag_id_1) { 3 }
    let!(:tag_id_2) { 5 }

    let!(:rule) { create :tagged_with }

    let!(:bob) { create :client, first_name: 'Bob', tags: {tag_id_1 => 5} }
    let!(:roy) { create :client, first_name: 'Roy', tags: {tag_id_2 => 3} }
    let!(:mary) { create :client, first_name: 'Mary', tags: {tag_id_1 => 2, tag_id_2 => 7} }
    let!(:sue) { create :client, first_name: 'Sue', tags: nil }

    let!(:positive) { create :requirement, rule: rule, positive: true, variable: tag_id_1 }
    let!(:negative) { create :requirement, rule: rule, positive: false, variable: tag_id_1 }

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