require 'rails_helper'

RSpec.describe Rules::Strength, type: :model do
  {
    strength: :strengths,
    challenge: :challenges,
  }.each do |rule_name, column_name|
    describe "clients that fit #{rule_name}" do
      let!(:rule) { create rule_name }

      let!(:bob) { create :client, first_name: 'Bob', column_name => ['reliable vehicle'] }
      let!(:roy) { create :client, first_name: 'Roy', column_name => ['regular income'] }
      let!(:mary) { create :client, first_name: 'Mary', column_name => ['reliable vehicle', 'regular income'] }
      let!(:sue) { create :client, first_name: 'Sue', column_name => [] }
      let!(:zelda) { create :client, first_name: 'Zelda', column_name => ['employable skills'] }

      let!(:positive) { create :requirement, rule: rule, positive: true, variable: 'reliable vehicle' }
      let!(:negative) { create :requirement, rule: rule, positive: false, variable: 'reliable vehicle' }
      let!(:multiple_positive) { create :requirement, rule: rule, positive: true, variable: 'reliable vehicle,employable skills' }
      let!(:multiple_negative) { create :requirement, rule: rule, positive: false, variable: 'reliable vehicle,employable skills' }

      let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
      let!(:clients_that_do_not_fit) { negative.clients_that_fit(Client.all) }
      let!(:clients_that_fit_multiple) { multiple_positive.clients_that_fit(Client.all) }
      let!(:clients_that_do_not_fit_multiple) { multiple_negative.clients_that_fit(Client.all) }

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
        it 'does not contain Zelda' do
          expect(clients_that_fit.ids).to_not include zelda.id
        end
      end

      context 'when negative' do
        it 'matches 3' do
          expect(clients_that_do_not_fit.count).to eq(3)
        end
        it 'does not contain Bob' do
          expect(clients_that_do_not_fit.ids).to_not include bob.id
        end
        it 'contains Roy' do
          expect(clients_that_do_not_fit.ids).to include roy.id
        end
        it 'does not contain Mary' do
          expect(clients_that_do_not_fit.ids).to_not include mary.id
        end
        it 'contains Sue' do
          expect(clients_that_do_not_fit.ids).to include sue.id
        end
        it 'contains Zelda' do
          expect(clients_that_do_not_fit.ids).to include zelda.id
        end
      end

      context 'when multiple positive' do
        it 'matches 3' do
          expect(clients_that_fit_multiple.count).to eq(3)
        end
        it 'contains Bob' do
          expect(clients_that_fit_multiple.ids).to include bob.id
        end
        it 'does not contain Roy' do
          expect(clients_that_fit_multiple.ids).to_not include roy.id
        end
        it 'contains Mary' do
          expect(clients_that_fit_multiple.ids).to include mary.id
        end
        it 'does not contain Sue' do
          expect(clients_that_fit_multiple.ids).to_not include sue.id
        end
        it 'does contains Zelda' do
          expect(clients_that_fit_multiple.ids).to include zelda.id
        end
      end

      context 'when multiple negative' do
        it 'matches 2' do
          expect(clients_that_do_not_fit_multiple.count).to eq(2)
        end
        it 'does not contain Bob' do
          expect(clients_that_do_not_fit_multiple.ids).to_not include bob.id
        end
        it 'contains Roy' do
          expect(clients_that_do_not_fit_multiple.ids).to include roy.id
        end
        it 'does not contain Mary' do
          expect(clients_that_do_not_fit_multiple.ids).to_not include mary.id
        end
        it 'contains Sue' do
          expect(clients_that_do_not_fit_multiple.ids).to include sue.id
        end
        it 'does not contains Zelda' do
          expect(clients_that_do_not_fit_multiple.ids).to_not include zelda.id
        end
      end
    end
  end
end
