require 'rails_helper'

RSpec.describe MatchDecisions::Base, type: :model do
  describe 'DND Match recommendation' do
    MatchRoutes::Base.ensure_all
    MatchPrioritization::Base.ensure_all
    let(:priority) { MatchPrioritization::DaysHomelessLastThreeYears.first }
    let(:route) {
      r = MatchRoutes::Default.first
      r.update(match_prioritization_id: priority.id, stalled_interval: 30)
      r
      }
    let(:program) { create :program, match_route: route }
    let(:sub_program) { create :sub_program, program: program }
    let(:voucher) { create :voucher, sub_program: sub_program }
    let(:opportunity) { create :opportunity, voucher: voucher }
    let!(:the_match) { create :client_opportunity_match, opportunity: opportunity, active: true }
    let(:a_dnd_decision) { create :match_decisions_match_recommendation_dnd_staff }

    let(:users) { create_list :user, 10 }
    let(:dnd_user) { users[0] }
    let(:hsa_user) { users[1] }
    let(:shelter_user) { users[2] }
    let(:shelter_user2) { users[5] }
    let(:hsp_user) { users[3] }
    let(:ssp_user) { users[4] }

    before(:each) do
      program = a_dnd_decision.program
      program.match_route = route

      the_match.dnd_staff_contacts << dnd_user.contact
      the_match.housing_subsidy_admin_contacts << hsa_user.contact
      the_match.shelter_agency_contacts << shelter_user.contact
      the_match.shelter_agency_contacts << shelter_user2.contact
      the_match.hsp_contacts << hsp_user.contact
      the_match.ssp_contacts << ssp_user.contact

      the_match.activate!
    end
    it 'there are no stalled matches initially' do
      expect(ClientOpportunityMatch.stalled.count).to be 0
    end
    describe 'when accepted' do
      let(:stalled_interval) { route.stalled_interval }
      before(:each) do
        dnd_decision = the_match.current_decision
        dnd_decision.update(status: :accepted)
        dnd_decision.run_status_callback!
      end
      it 'the current decision should be the shelter decision' do
        expect(the_match.current_decision.class.name).to eq 'MatchDecisions::MatchRecommendationShelterAgency'
      end
      it 'the match still doesn\'t have a stall date' do
        expect(the_match.stall_date).to be nil
      end
      describe 'when shelter agency accepts' do
        before(:each) do
          shelter_decision = the_match.current_decision
          shelter_decision.update(status: :accepted)
          shelter_decision.run_status_callback!
        end
        it 'the match should have a stall date in the future' do
          expect(the_match.stall_date.present?).to be true
        end
        it 'the match gains a future stall date' do
          expect(the_match.stall_date).to be > Date.today
        end
        it 'the match should not be stalled' do
          expect(the_match.stalled?).to be false
        end
        it 'when time passes, the match becomes stalled' do
          Timecop.travel(Date.today + stalled_interval + 1) do
            expect(the_match.stalled?).to be true
          end
        end
        describe 'when a stalled notice is submitted, the match un-stalls' do
          before(:each) do
            # This happens when the status update is submitted
            the_match.current_decision.set_stall_date()
          end
          it 'the match should not be stalled' do
            expect(the_match.stalled?).to be false
          end
        end
        describe 'when a decision is updated, the match un-stalls' do
          before(:each) do
            the_decision = the_match.current_decision
            the_decision.update(status: :scheduled)
            the_decision.run_status_callback!
          end
          it 'the match should not be stalled' do
            expect(the_match.stalled?).to be false
          end
        end
      end
    end
  end
end