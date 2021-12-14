require 'rails_helper'

RSpec.describe Rules::AssessmentCompletedWithin, type: :model do
  let!(:rule) { create :assessment_completed_within }

  let!(:bob) do
    create :client, first_name: 'Bob', rrh_assessment_collected_at: 93.days.ago.to_date
  end
  let!(:roy) do
    create :client, first_name: 'Roy', rrh_assessment_collected_at: 33.days.ago.to_date
  end
  let!(:mary) do
    create :client, first_name: 'Mary', rrh_assessment_collected_at: 2.years.ago.to_date
  end
  let!(:positive) { create :requirement, rule: rule, positive: true, variable: 90 }
  let!(:negative) { create :requirement, rule: rule, positive: false, variable: 90 }
  let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
  let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }

  describe 'clients_that_fit' do
    context 'when positive' do
      it 'matches 1' do
        expect(clients_that_fit.count).to eq 1
      end
      it 'contains Roy' do
        expect(clients_that_fit.ids).to include roy.id
      end
      it 'does not contain Bob' do
        expect(clients_that_fit.ids).to_not include bob.id
      end
      it 'does not contain Mary' do
        expect(clients_that_fit.ids).to_not include mary.id
      end
    end
    context 'when negative' do
      it 'matches 2' do
        expect(clients_that_dont_fit.count).to eq 2
      end
      it 'contains Bob' do
        expect(clients_that_dont_fit.ids).to include bob.id
      end
      it 'contains Mary' do
        expect(clients_that_dont_fit.ids).to include mary.id
      end
      it 'does not contain Roy' do
        expect(clients_that_dont_fit.ids).to_not include roy.id
      end
    end
  end
end
