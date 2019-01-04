require 'rails_helper'

RSpec.describe Rules::EnrolledInHmisProject, type: :model do
  describe 'clients_that_fit' do

    let!(:project_a) { create :project_a }
    let!(:project_b) { create :project_b }

    let!(:rule) { create :enrolled_in_hmis_project_a }

    let!(:bob) { create :client, first_name: 'Bob', enrolled_project_ids: [ project_a.id ] }
    let!(:roy) { create :client, first_name: 'Roy', enrolled_project_ids: [ project_b.id ] }
    let!(:mary) { create :client, first_name: 'Mary', enrolled_project_ids: [ project_a.id, project_b.id ] }
    let!(:sue) { create :client, first_name: 'Sue', enrolled_project_ids: nil }
    let!(:zelda) { create :client, first_name: 'Zelda', enrolled_project_ids: [ "#{project_a.id}" ] }

    let!(:positive) { create :requirement, rule: rule, positive: true, variable: project_a.id }
    let!(:negative) { create :requirement, rule: rule, positive: false, variable: project_a.id }

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
      it 'does not contain Zelda' do
        expect(clients_that_fit.ids).to_not include zelda.id
      end
    end

    context 'when negative' do
      it 'matches 3' do
        expect(clients_that_dont_fit.count).to eq(3)
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
      it 'contains Zelda' do
        expect(clients_that_dont_fit.ids).to include zelda.id
      end
    end

  end
end
