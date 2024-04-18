require 'rails_helper'

RSpec.describe Rules::EnrolledInHmisProjectTypeAnyPhNoMoveIn, type: :model do
  describe 'clients_that_fit' do
    let!(:rule) { create :enrolled_in_hmis_project_type_any_ph_no_move_in }

    let!(:bob) { create :client, first_name: 'Bob', enrolled_in_ph_pre_move_in: false, enrolled_in_psh_pre_move_in: false }
    let!(:roy) { create :client, first_name: 'Roy', enrolled_in_ph_pre_move_in: true, enrolled_in_psh_pre_move_in: false }
    let!(:mary) { create :client, first_name: 'Mary', enrolled_in_ph_pre_move_in: false, enrolled_in_psh_pre_move_in: true }
    let!(:sue) { create :client, first_name: 'Sue', enrolled_in_ph_pre_move_in: false, enrolled_in_psh_pre_move_in: true }
    let!(:zelda) { create :client, first_name: 'Zelda', enrolled_in_ph_pre_move_in: true, enrolled_in_psh_pre_move_in: true }

    let!(:positive_ph) { create :requirement, rule: rule, positive: true, variable: 'ph' }
    let!(:positive_psh) { create :requirement, rule: rule, positive: true, variable: 'psh' }
    let!(:negative_ph) { create :requirement, rule: rule, positive: false, variable: 'ph' }
    let!(:multi_positive) { create :requirement, rule: rule, positive: true, variable: 'ph,psh' }
    let!(:multi_negative) { create :requirement, rule: rule, positive: false, variable: 'ph,psh' }

    let!(:clients_that_fit_ph) { positive_ph.clients_that_fit(Client.all) }
    let!(:clients_that_dont_fit_ph) { negative_ph.clients_that_fit(Client.all) }
    let!(:clients_that_fit_multi) { multi_positive.clients_that_fit(Client.all) }
    let!(:clients_that_dont_fit_multi) { multi_negative.clients_that_fit(Client.all) }

    context 'when positive ph' do
      it 'matches 2' do
        expect(clients_that_fit_ph.count).to eq(2)
      end
    end

    context 'when negative ph' do
      it 'matches 2' do
        expect(clients_that_dont_fit_ph.count).to eq(3)
      end
    end

    context 'when positive multi' do
      it 'matches 4' do
        expect(clients_that_fit_multi.count).to eq(4)
      end
    end

    context 'when negative multi' do
      it 'matches 1' do
        expect(clients_that_dont_fit_multi.count).to eq(1)
      end
    end
  end
end
