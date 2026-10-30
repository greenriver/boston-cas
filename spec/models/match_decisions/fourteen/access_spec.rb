###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Match Route Fourteen decision access', type: :model do
  let(:route) { MatchRoutes::Fourteen.first }
  let(:match) { create :client_opportunity_match, match_route: route }
  let(:contacts) do
    [:shelter_agency_contacts, :housing_subsidy_admin_contacts, :ssp_contacts, :hsp_contacts, :dnd_staff_contacts].index_with { create(:contact) }
  end

  before { contacts.each { |type, contact| match.send(type) << contact } }

  MatchRoutes::Fourteen.match_steps_for_reporting.each_key do |decision_class|
    it "#{decision_class} is accessible only to contacts of its actor type" do
      decision = match.send("#{decision_class.demodulize.underscore}_decision")
      accessible = contacts.select { |_type, contact| decision.accessible_by?(contact) }.keys

      expect(accessible).to contain_exactly(decision.contact_actor_type)
    end
  end

  describe 'a contact who is not on the match' do
    let(:outsider) { create(:contact) }
    let(:decision) { match.fourteen_subsidy_admin_screening_decision }

    it 'has no access' do
      expect(decision.accessible_by?(outsider)).to be false
    end

    it 'has access when their user can act on behalf of match contacts' do
      create(:user, contact: outsider).roles << create(:role, can_act_on_behalf_of_match_contacts: true)

      expect(decision.accessible_by?(outsider)).to be true
    end
  end
end
