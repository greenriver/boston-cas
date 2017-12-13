require 'rails_helper'

RSpec.describe Client, type: :model do

  describe 'prioritized' do
    context 'when engine_mode is vispdat-priority-score' do
      before(:each) do
        allow(Config).to receive(:get).with(:engine_mode).and_return('vispdat-priority-score')
      end
      it 'is an ActiveRecord::Relation' do
        expect( Client.prioritized ).to be_an ActiveRecord::Relation
      end
      it 'orders by vispdat_priority_score' do
        expect( Client.prioritized ).to eq Client.where.not(vispdat_priority_score: nil).order(vispdat_priority_score: :desc)
      end
    end
  end

  let(:bob_smith) { create :client, first_name: 'Bob', last_name: 'Smith' }
  let(:joe_smith) { create :client, first_name: 'Joe', last_name: 'Smith' }
  let(:ray_jones) { create :client, first_name: 'Ray', last_name: 'Jones' }
  let(:ray_clark) { create :client, first_name: 'Ray', last_name: 'Clark' }
  let(:ben_chris) { create :client, first_name: 'Ben', last_name: 'Chris', alternate_names: 'Bobby Ray,Lee Jones' }
  let(:clients) { [bob_smith, joe_smith, ray_jones, ray_clark, ben_chris] }
  let(:match_bob) { Client.where(Client.match_first_name('Bob')) }

  describe 'match_first_name' do
    before(:each) do
      clients
    end
    context 'when searching Bob' do
      it 'matches one' do
        expect( match_bob.count ).to eq 1
      end
      it 'matches Bob' do
        expect( match_bob ).to include bob_smith
      end
      it 'does not match Joe Smith' do
        expect( match_bob ).to_not include joe_smith
      end
    end
  end

  let(:match_smith) { Client.where(Client.match_last_name('Smith')) }

  describe 'match_last_name' do
    before(:each) do
      clients
    end
    context 'when searching Smith' do
      it 'matches 2' do
        expect( match_smith.count ).to eq 2
      end
      it 'matches Bob' do
        expect( match_smith ).to include bob_smith
      end
      it 'matches Joe' do
        expect( match_smith ).to include joe_smith
      end
      it 'does not match either Rays' do
        expect( match_smith ).to_not include ray_jones, ray_clark
      end
    end
  end

  let(:match_alternate_jones) { Client.where(Client.match_alternate_name('Jones')) }

  describe 'match_alternate_name' do
    before(:each) do
      clients
    end
    context 'when searching Jones' do
      it 'matches 1' do
        expect( match_alternate_jones.count ).to eq 1
      end
      it 'matches Ben' do
        expect( match_alternate_jones ).to include ben_chris
      end
      it 'does not match anyone else' do
        expect( match_alternate_jones ).to_not include *(clients - [ben_chris])
      end
    end
  end

  let(:ray_search) do 
    Client.where(
      Client.match_first_name('Ray')
      .or(Client.match_alternate_name('Ray')))
  end
  let(:bob_search) do
    Client.where(
      Client.match_first_name('Bob')
      .or(Client.match_alternate_name('Bob')))
  end

  describe 'combo match on first & alternate' do
    before(:each) do
      clients
    end
    context 'when searching Ray' do
      it 'matches 3' do
        expect( ray_search.count ).to eq 3
      end
    end
    context 'when searching Bob' do
      it 'matches 2' do
        expect( bob_search.count ).to eq 2
      end
    end
  end

end
