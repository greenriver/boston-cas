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

end
