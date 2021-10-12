require 'rails_helper'

RSpec.describe Rules::NonHmisAssessmentType, type: :model do
  describe 'clients_that_fit' do
    let!(:rule) { create :non_hmis_assessment_type }

    let!(:bob) { create :client, first_name: 'Bob', assessment_name: IdentifiedClientAssessment.new.for_matching.keys.first }
    let!(:roy) { create :client, first_name: 'Roy', assessment_name: DeidentifiedPathwaysAssessment.new.for_matching.keys.first }
    let!(:mary) { create :client, first_name: 'Mary', assessment_name: IdentifiedPathwaysVersionThree.new(assessment_type: :pathways_2021).for_matching.keys.first }
    let!(:sue) { create :client, first_name: 'Sue', assessment_name: nil }
    let!(:zelda) { create :client, first_name: 'Zelda', assessment_name: DeidentifiedPathwaysVersionThree.new(assessment_type: :transfer_assessment).for_matching.keys.first }

    let!(:identified_assessment_positive) { create :requirement, rule: rule, positive: true, variable: 'IdentifiedClientAssessment' }
    let!(:identified_assessment_negative) { create :requirement, rule: rule, positive: false, variable: 'IdentifiedClientAssessment' }
    let!(:multi_positive) { create :requirement, rule: rule, positive: true, variable: 'IdentifiedClientAssessment,DeidentifiedPathwaysVersionThreeTransfer' }

    let!(:clients_that_fit) { identified_assessment_positive.clients_that_fit(Client.all) }
    let!(:clients_that_dont_fit) { identified_assessment_negative.clients_that_fit(Client.all) }
    let!(:clients_that_fit_multi) { multi_positive.clients_that_fit(Client.all) }

    context 'when positive' do
      it 'matches 1' do
        expect(clients_that_fit.count).to eq(1)
      end
      it 'contains Bob' do
        expect(clients_that_fit.ids).to include bob.id
      end
      it 'does not contain Roy' do
        expect(clients_that_fit.ids).to_not include roy.id
      end
      it 'does not contain Mary' do
        expect(clients_that_fit.ids).to_not include mary.id
      end
      it 'does not contain Sue' do
        expect(clients_that_fit.ids).to_not include sue.id
      end
      it 'does not contain Zelda' do
        expect(clients_that_fit.ids).to_not include zelda.id
      end
    end

    context 'when negative' do
      it 'matches 4' do
        expect(clients_that_dont_fit.count).to eq(4)
      end
      it 'does not contain Bob' do
        expect(clients_that_dont_fit.ids).to_not include bob.id
      end
      it 'contains Roy' do
        expect(clients_that_dont_fit.ids).to include roy.id
      end
      it 'contains Mary' do
        expect(clients_that_dont_fit.ids).to include mary.id
      end
      it 'contains Sue' do
        expect(clients_that_dont_fit.ids).to include sue.id
      end
      it 'contains Zelda' do
        expect(clients_that_dont_fit.ids).to include zelda.id
      end
    end

    context 'when multiple' do
      it 'matches 2' do
        expect(clients_that_fit_multi.count).to eq(2)
      end
      it 'contains Bob' do
        expect(clients_that_fit_multi.ids).to include bob.id
      end
      it 'does not contain Roy' do
        expect(clients_that_fit_multi.ids).to_not include roy.id
      end
      it 'does not contain Mary' do
        expect(clients_that_fit_multi.ids).to_not include mary.id
      end
      it 'does not contain Sue' do
        expect(clients_that_fit_multi.ids).to_not include sue.id
      end
      it 'contains Zelda' do
        expect(clients_that_fit_multi.ids).to include zelda.id
      end
    end
  end
end
