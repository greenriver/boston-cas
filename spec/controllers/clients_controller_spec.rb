require 'rails_helper'

RSpec.describe ClientsController, type: :controller do

  let(:admin)       { create(:user) }
  let(:admin_role)  { create :admin_role }

  before do
    authenticate admin
    admin.roles << admin_role
  end

  describe 'GET #index' do
    describe 'engine_mode' do
      context 'is vispdat-priority-score' do
        before(:each) do
          allow(Config).to receive(:get).with(:engine_mode).and_return 'vispdat-priority-score'
          get :index
        end
        it 'sets column to vispdat_priority_score' do
          expect( assigns(:column) ).to eq 'vispdat_priority_score'
        end
        it 'sets direction to desc' do
          expect( assigns(:direction) ).to eq 'desc'
        end
        it 'set sorted_by to VI-SPDAT priority score' do
          expect( assigns(:sorted_by) ).to eq 'VI-SPDAT priority score'
        end
      end
    end
  end

end