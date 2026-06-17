###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

require 'rails_helper'

RSpec.describe Rules::PshRequired, type: :model do
  describe 'clients_that_fit' do
    let!(:rule) { create :psh_required }

    let!(:bob) { create :client, first_name: 'Bob', psh_required: 'yes' }
    let!(:roy) { create :client, first_name: 'Roy', psh_required: 'no' }
    let!(:job) { create :client, first_name: 'Roy', psh_required: 'maybe' }

    let!(:positive) { create :requirement, rule: rule, positive: true }
    let!(:negative) { create :requirement, rule: rule, positive: false }

    let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
    let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }

    context 'when positive' do
      it 'matches 2' do
        expect(clients_that_fit.count).to eq(2)
      end
      it 'contains Bob and Job' do
        expect(clients_that_fit.ids).to include bob.id
        expect(clients_that_fit.ids).to include job.id
      end
      it 'does not contain Roy' do
        expect(clients_that_fit.ids).to_not include roy.id
      end
    end

    context 'when negative' do
      it 'matches 2' do
        expect(clients_that_dont_fit.count).to eq(2)
      end
      it 'does not contain Bob' do
        expect(clients_that_dont_fit.ids).to_not include bob.id
      end
      it 'contains Roy and Job' do
        expect(clients_that_dont_fit.ids).to include roy.id
        expect(clients_that_dont_fit.ids).to include job.id
      end
    end
  end
end
