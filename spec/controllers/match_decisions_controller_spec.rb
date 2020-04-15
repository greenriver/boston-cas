require 'rails_helper'

RSpec.describe MatchDecisionsController, type: :controller do
  let!(:admin) { create(:user) }
  let!(:admin_role) { create :admin_role }
  let!(:priority) { create :priority_vispdat_priority }
  let!(:route) { create :default_route, match_prioritization: priority }
  let!(:program) { create :program, match_route: route }
  let!(:sub_program) { create :sub_program, program: program }
  let!(:voucher) { create :voucher, sub_program: sub_program }
  let!(:opportunity) { create :opportunity, voucher: voucher }
  let!(:decision) { create :match_decisions_match_recommendation_dnd_staff}
  let!(:match) { create :client_opportunity_match, match_route: route, opportunity: opportunity }

  before do
    authenticate admin
    admin.roles << admin_role

    match.match_recommendation_dnd_staff_decision.update(status: 'pending')
  end

  describe 'When parking' do
    describe 'before parking happens' do
      let!(:hsa_decision) { create :match_decisions_match_recommendation_hsa_housing_date }
      let!(:other_match) { create :client_opportunity_match, match_route: route, client: match.client }

      it 'client has two active matches' do
        aggregate_failures 'checking counts' do
          expect(match.client.client_opportunity_matches.active.count).to eq(2)
        end
      end
      describe 'after parking' do
        before(:each) do
          patch :update, params: { match_id: match.id, id: 'match_recommendation_dnd_staff', decision: attributes_for(:match_decisions_match_recommendation_hsa_housing_date, :canceled, :parked, administrative_cancel_reason_id: [24], prevent_matching_until: Date.current + 2.days) }
        end
        it 'client has one active match' do
          aggregate_failures 'checking counts' do
            expect(flash[:error]).not_to be_present
            expect(match.client.client_opportunity_matches.active.count).to eq(1)
            expect(match.client.client_opportunity_matches.active.first).to eq(other_match)
          end
        end

        it 'client has been made unavailable on route' do
          aggregate_failures 'checking counts' do
            expect(flash[:error]).not_to be_present
            expect(Client.unavailable_in(match.match_route).pluck(:id).include?(match.client.id)).to eq(true)
          end
        end

      end
    end

  end

  describe 'PUT #update' do
    context 'with valid attributes' do
      before(:each) do
        patch :update, params: { match_id: match.id, id: 'match_recommendation_dnd_staff', decision: attributes_for(:match_decisions_match_recommendation_dnd_staff) }
      end

      it "redirects to match#show" do
        expect(response).to redirect_to match_path(match, redirect: "true")
      end
    end

    context 'with invalid attributes' do

      context "if expiration date is provided and match is declined" do
        before(:each) do
          patch :update, params: { match_id: match.id, id: 'match_recommendation_dnd_staff', decision: attributes_for(:match_decisions_match_recommendation_dnd_staff, :declined, :shelter_expiration) }
        end

        it "flashes an error" do
          expect(flash[:error]).to be_present
        end

        it "renders #show" do
          expect(response).to render_template ('matches/show')
        end
      end

      context "if we've been asked to park the client and match is accepted" do
        before(:each) do
          patch :update, params: { match_id: match.id, id: 'match_recommendation_dnd_staff', decision: attributes_for(:match_decisions_match_recommendation_dnd_staff, :accepted, :parked) }
        end

        it "flashes an error" do
          expect(flash[:error]).to be_present
        end

        it "renders #show" do
          expect(response).to render_template ('matches/show')
        end
      end

      context "if cancel reason is provided and match is declined" do
        before(:each) do
          patch :update, params: { match_id: match.id, id: 'match_recommendation_dnd_staff', decision: attributes_for(:match_decisions_match_recommendation_dnd_staff, :declined, :cancel_reason) }
        end

        it "flashes an error" do
          expect(flash[:error]).to be_present
        end

        it "renders #show" do
          expect(response).to render_template ('matches/show')
        end
      end

      context "if cancel reason is provided and match is accepted" do
        before(:each) do
          patch :update, params: { match_id: match.id, id: 'match_recommendation_dnd_staff', decision: attributes_for(:match_decisions_match_recommendation_dnd_staff, :accepted, :cancel_reason) }
        end

        it "flashes an error" do
          expect(flash[:error]).to be_present
        end

        it "renders #show" do
          expect(response).to render_template ('matches/show')
        end
      end

      context "if decline reason is provided and match is accepted" do
        before(:each) do
          patch :update, params: { match_id: match.id, id: 'match_recommendation_dnd_staff', decision: attributes_for(:match_decisions_match_recommendation_dnd_staff, :accepted, :decline_reason) }
        end

        it "flashes an error" do
          expect(flash[:error]).to be_present
        end

        it "renders #show" do
          expect(response).to render_template ('matches/show')
        end
      end

      context "if decline reason is provided and match is canceled" do
        before(:each) do
          patch :update, params: { match_id: match.id, id: 'match_recommendation_dnd_staff', decision: attributes_for(:match_decisions_match_recommendation_dnd_staff, :canceled, :decline_reason) }
        end

        it "flashes an error" do
          expect(flash[:error]).to be_present
        end

        it "renders #show" do
          expect(response).to render_template ('matches/show')
        end
      end

      context "if cancel reason is not provided and match is canceled" do
        before(:each) do
          patch :update, params: { match_id: match.id, id: 'match_recommendation_dnd_staff', decision: attributes_for(:match_decisions_match_recommendation_dnd_staff, :canceled, :cancel_reason_absent) }
        end

        it "flashes an error" do
          expect(flash[:error]).to be_present
        end

        it "renders #show" do
          expect(response).to render_template ('matches/show')
        end
      end
    end
  end
end
