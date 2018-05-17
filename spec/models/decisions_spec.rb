require 'rails_helper'

RSpec.describe MatchDecisions::Base, type: :model do
  describe 'DND Match recommendation' do
    MatchRoutes::Base.ensure_all
    MatchPrioritization::Base.ensure_all
    let(:priority) { MatchPrioritization::DaysHomelessLastThreeYears.first }
    let(:route) { 
      r = MatchRoutes::Default.first 
      r.update(match_prioritization_id: priority.id, stalled_interval: 7)
      r
      }
    let(:dnd_decision) { create :match_decisions_match_recommendation_dnd_staff }
    let(:shelter_decision) { create :match_decisions_match_recommendation_shelter_agency }
    let(:users) { create_list :user, 10 }
    let(:dnd_user) { users[0] }
    let(:hsa_user) { users[1] }
    let(:shelter_user) { users[2] }
    let(:shelter_user2) { users[5] }
    let(:hsp_user) { users[3] }
    let(:ssp_user) { users[4] }

    before(:each) do 
      match = dnd_decision.match
      shelter_decision.match = match
      program = dnd_decision.program
      program.match_route = route
      match.dnd_staff_contacts << dnd_user.contact
      match.housing_subsidy_admin_contacts << hsa_user.contact
      match.shelter_agency_contacts << shelter_user.contact
      match.shelter_agency_contacts << shelter_user2.contact
      match.hsp_contacts << hsp_user.contact
      match.ssp_contacts << ssp_user.contact
    end
    it 'there are no match progress update request initially' do
      expect(MatchProgressUpdates::Base.count).to be 0
    end
    describe 'when accepted' do
      let(:stalled_interval) { route.stalled_interval }
      before(:each) do
        dnd_decision.update(status: :accepted)
        dnd_decision.run_status_callback!
        shelter_decision.update(status: :pending)
      end
      it 'sets up progress updates for HSP' do
        expect(MatchProgressUpdates::Hsp.pluck(:contact_id).sort).to eq [hsp_user.contact.id].sort
      end
      it 'sets up progress updates for SSP' do
        expect(MatchProgressUpdates::Ssp.pluck(:contact_id).sort).to eq [ssp_user.contact.id].sort
      end
      it 'sets up progress updates for Shelter Agency' do
        expect(MatchProgressUpdates::ShelterAgency.pluck(:contact_id).sort).to eq [shelter_user.contact.id, shelter_user2.contact.id].sort
      end
      it 'does not expect any responses immediately' do
        expect(MatchProgressUpdates::Base.outstanding_contacts_for_stalled_matches.size).to be 0
      end
      it "does not expect any responses before one stalled interval has passed" do 
        Timecop.travel(Date.today + stalled_interval - 1) do 
          expect(MatchProgressUpdates::Base.outstanding_contacts_for_stalled_matches.size).to be 0
        end
      end
      it "expect some responses after one stalled interval has passed" do 
        Timecop.travel(Date.today + stalled_interval + 1) do 
          MatchProgressUpdates::Base.send_notifications
          contacts_for_stalled_matches_ids = MatchProgressUpdates::Base.outstanding_contacts_for_stalled_matches.map(&:first).uniq.sort
          contact_ids = [
            shelter_user.contact.id,
            shelter_user2.contact.id,
            hsp_user.contact.id,
            ssp_user.contact.id,
          ].uniq.sort
          expect(contacts_for_stalled_matches_ids).to eq contact_ids
        end
      end

      it "expect the same responses after three stalled intervals have passed" do 
        Timecop.travel(Date.today + stalled_interval * 3) do 
          MatchProgressUpdates::Base.send_notifications
          contacts_for_stalled_matches_ids = MatchProgressUpdates::Base.outstanding_contacts_for_stalled_matches.map(&:first).uniq.sort
          contact_ids = [
            shelter_user.contact.id,
            shelter_user2.contact.id,
            hsp_user.contact.id,
            ssp_user.contact.id,
          ].uniq.sort
          expect(contacts_for_stalled_matches_ids).to eq contact_ids
        end
      end

      it "expect different responses after someone has submitted a response" do 
        Timecop.travel(Date.today + stalled_interval + 1) do 
          MatchProgressUpdates::Base.send_notifications

          update = MatchProgressUpdates::ShelterAgency.incomplete_for_contact(contact_id: shelter_user.contact.id).
            where(match_id: shelter_decision.match.id).first
          update.response = 'Client disappeared'
          update.client_last_seen = Date.yesterday
          update.submitted_at = Time.now
          update.submit!

          contacts_for_stalled_matches_ids = MatchProgressUpdates::Base.incomplete.
            outstanding_contacts_for_stalled_matches.map(&:first).uniq.sort
          contact_ids = [
            shelter_user2.contact.id,
            hsp_user.contact.id,
            ssp_user.contact.id,
          ].uniq.sort
          expect(contacts_for_stalled_matches_ids).to eq contact_ids
        end
      end

      # TODO 
      #   Move forward after submitting one far enough that we should re-request it
      #   verify that the re-request goes in and creates a second request
      #   but only for the contact who previously submitted
      #   
      #   Submit all and verify it no longer requests updates
      #   
      #   Verify that appropriate notifications are created when sending notifications before and after a 
      #   submission
      #   
      #   Do this all again on a the provider only route
    end
  end
end