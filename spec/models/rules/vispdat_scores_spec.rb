require 'rails_helper'

RSpec.describe Rules::VispdatScoreThreeOrLess, type: :model do

  let!(:rule) { create :vispdat_less_than_3 }

  let!(:bob) { 
    client = create :client, first_name: 'Bob', vispdat_score: 4
  }
  let!(:roy) {
    client = create :client, first_name: 'Roy', vispdat_score: 1
  }
  let!(:positive) { create :requirement, rule: rule, positive: true }
  let!(:negative) { create :requirement, rule: rule, positive: false }
  let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
  let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }


  
  describe 'clients_that_fit' do

    context 'when positive' do
      it 'matches 1' do
        expect( clients_that_fit.count ).to eq 1
      end
      it 'contains Roy' do
        expect( clients_that_fit.ids ).to include roy.id
      end
      it 'does not contain Bob' do
        expect( clients_that_fit.ids ).to_not include bob.id
      end
    end
    context 'when negative' do
      it 'matches 1' do
        expect(clients_that_dont_fit.count).to eq 1
      end
      it 'contains Bob' do
        expect( clients_that_dont_fit.ids ).to include bob.id
      end
      it 'does not contain Roy' do
        expect( clients_that_dont_fit.ids ).to_not include roy.id
      end
    end
  end
end

RSpec.describe Rules::VispdatScoreFourOrLess, type: :model do

  let!(:rule) { create :vispdat_less_than_4 }

  let!(:bob) {
    client = create :client, first_name: 'Bob', vispdat_score: 5
  }
  let!(:roy) {
    client = create :client, first_name: 'Roy', vispdat_score: 4
  }
  let!(:positive) { create :requirement, rule: rule, positive: true }
  let!(:negative) { create :requirement, rule: rule, positive: false }
  let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
  let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }



  describe 'clients_that_fit' do

    context 'when positive' do
      it 'matches 1' do
        expect( clients_that_fit.count ).to eq 1
      end
      it 'contains Roy' do
        expect( clients_that_fit.ids ).to include roy.id
      end
      it 'does not contain Bob' do
        expect( clients_that_fit.ids ).to_not include bob.id
      end
    end
    context 'when negative' do
      it 'matches 1' do
        expect(clients_that_dont_fit.count).to eq 1
      end
      it 'contains Bob' do
        expect( clients_that_dont_fit.ids ).to include bob.id
      end
      it 'does not contain Roy' do
        expect( clients_that_dont_fit.ids ).to_not include roy.id
      end
    end
  end
end

RSpec.describe Rules::VispdatScoreFourToSeven, type: :model do

  let!(:rule) { create :vispdat_between_4_and_7 }

  let!(:bob) { 
    client = create :client, first_name: 'Bob', vispdat_score: 1
  }
  let!(:roy) {
    client = create :client, first_name: 'Roy', vispdat_score: 5
  }
  let!(:mary) {
    client = create :client, first_name: 'Mary', vispdat_score: 8
  }
  let!(:positive) { create :requirement, rule: rule, positive: true }
  let!(:negative) { create :requirement, rule: rule, positive: false }
  let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
  let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }


  
  describe 'clients_that_fit' do

    context 'when positive' do
      it 'matches 1' do
        expect( clients_that_fit.count ).to eq 1
      end
      it 'contains Roy' do
        expect( clients_that_fit.ids ).to include roy.id
      end
      it 'does not contain Bob' do
        expect( clients_that_fit.ids ).to_not include bob.id
      end
      it 'does not contain Mary' do
        expect( clients_that_fit.ids ).to_not include mary.id
      end
    end
    context 'when negative' do
      it 'matches 2' do
        expect(clients_that_dont_fit.count).to eq 2
      end
      it 'contains Bob' do
        expect( clients_that_dont_fit.ids ).to include bob.id
      end
      it 'contains Mary' do
        expect( clients_that_dont_fit.ids ).to include mary.id
      end
      it 'does not contain Roy' do
        expect( clients_that_dont_fit.ids ).to_not include roy.id
      end
    end
  end
end

RSpec.describe Rules::VispdatScoreEightOrMore, type: :model do

  let!(:rule) { create :vispdat_more_than_8 }

  let!(:bob) { 
    client = create :client, first_name: 'Bob', vispdat_score: 1
  }
  let!(:roy) {
    client = create :client, first_name: 'Roy', vispdat_score: 8
  }
  let!(:mary) {
    client = create :client, first_name: 'Mary', vispdat_score: 7
  }
  let!(:positive) { create :requirement, rule: rule, positive: true }
  let!(:negative) { create :requirement, rule: rule, positive: false }
  let!(:clients_that_fit) { positive.clients_that_fit(Client.all) }
  let!(:clients_that_dont_fit) { negative.clients_that_fit(Client.all) }


  
  describe 'clients_that_fit' do

    context 'when positive' do
      it 'matches 1' do
        expect( clients_that_fit.count ).to eq 1
      end
      it 'contains Roy' do
        expect( clients_that_fit.ids ).to include roy.id
      end
      it 'does not contain Bob' do
        expect( clients_that_fit.ids ).to_not include bob.id
      end
      it 'does not contain Mary' do
        expect( clients_that_fit.ids ).to_not include mary.id
      end
    end
    context 'when negative' do
      it 'matches 2' do
        expect(clients_that_dont_fit.count).to eq 2
      end
      it 'contains Bob' do
        expect( clients_that_dont_fit.ids ).to include bob.id
      end
      it 'contains Mary' do
        expect( clients_that_dont_fit.ids ).to include mary.id
      end
      it 'does not contain Roy' do
        expect( clients_that_dont_fit.ids ).to_not include roy.id
      end
    end
  end
end
