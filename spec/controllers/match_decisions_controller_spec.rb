require 'rails_helper'

RSpec.describe MatchDecisionsController, type: :controller do
  let(:admin) { create(:user) }
  let(:admin_role) { create :admin_role }
  let(:decision) { create :match_decisions_match_recommendation_dnd_staff}
  let(:match) { create :client_opportunity_match }

  before do
    authenticate admin
    admin.roles << admin_role
    
    match.match_recommendation_dnd_staff_decision.update(status: 'pending')
  end
  
  describe 'PUT #update' do 
    context 'with valid params' do
      before(:each) do
        patch :update, match_id: match.id, id: 'match_recommendation_dnd_staff', decision: attributes_for(:match_decisions_match_recommendation_dnd_staff)
      end
    
      it "redirects to match#show" do
        expect(response).to redirect_to match_path(match, redirect: "true")
      end
    end
    
    context "If expiration date is provided and match is declined" do
      before(:each) do
        patch :update, match_id: match.id, id: 'match_recommendation_dnd_staff', decision: attributes_for(:match_decisions_match_recommendation_dnd_staff, :declined, :shelter_expiration)
      end
      
      it "flashes an error" do 
        expect(flash[:error]).to be_present
      end
      
      it "renders #show" do
        expect(response).to render_template ('matches/show')
      end
    end
    
    context "If we've been asked to park the client and match is accepted" do
      before(:each) do
        patch :update, match_id: match.id, id: 'match_recommendation_dnd_staff', decision: attributes_for(:match_decisions_match_recommendation_dnd_staff, :accepted, :parked)
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
