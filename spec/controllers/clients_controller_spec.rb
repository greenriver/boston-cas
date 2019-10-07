require 'rails_helper'

RSpec.describe ClientsController, type: :controller do
  let!(:admin) { create(:user) }
  let!(:admin_role) { create :admin_role }
  let!(:decision) { create :match_decisions_match_recommendation_dnd_staff}
  let!(:priority) { create :priority_vispdat_priority }
  let!(:route) { create :default_route, match_prioritization: priority }
  let!(:program) { create :program, match_route: route }
  let!(:sub_program) { create :sub_program, program: program }
  let!(:voucher) { create :voucher, sub_program: sub_program }
  let!(:opportunity) { create :opportunity, voucher: voucher }
  let!(:match) { create :client_opportunity_match, match_route: route, opportunity: opportunity }

  before do
    authenticate admin
    admin.roles << admin_role

    match.match_recommendation_dnd_staff_decision.update(status: 'pending')
  end

  describe 'When parking' do
    describe 'before parking happens' do
      let!(:hsa_decision) { create :match_decisions_match_recommendation_hsa_housing_date }
      let!(:other_voucher) { create :voucher, sub_program: sub_program }
      let!(:other_opportunity) { create :opportunity, voucher: other_voucher }
      let!(:other_match) { create :client_opportunity_match, client: match.client, match_route: route, opportunity: other_opportunity }

      it 'client has two active matches' do
        aggregate_failures 'checking counts' do
          expect(match.client.client_opportunity_matches.active.count).to eq(2)
        end
      end
      describe 'after parking' do
        before(:each) do
          patch :update, client: {prevent_matching_until: Date.today + 2.days}, id: match.client.id
        end
        it 'client no longer has any active matches' do
          aggregate_failures 'checking counts' do
            expect(flash[:error]).not_to be_present
            expect(match.client.client_opportunity_matches.active.count).to eq(0)
          end
        end

        it 'client has been made unavailable' do
          aggregate_failures 'checking counts' do
            expect(flash[:error]).not_to be_present
            expect(match.client.available_as_candidate_for_any_route?).to eq(false)
          end
        end

      end
    end
  end
end
