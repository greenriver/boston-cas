###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MatchDecisions::ApproveMatchHousingSubsidyAdmin, type: :model do
  let(:match) { create(:client_opportunity_match) }
  let(:decision) { described_class.create!(match: match) }
  let(:shelter_agency_contact) { create(:contact) }
  let(:hsa_contact) { create(:contact) }
  let(:on_behalf_of_admin) do
    admin = create(:user)
    admin.roles << create(:admin_role)
    admin.contact
  end

  before do
    match.shelter_agency_contacts << shelter_agency_contact
    match.housing_subsidy_admin_contacts << hsa_contact
    CasSeeds::MatchDecisionReasons.new.run!
    CasSeeds::MatchDecisionReasonAssignments.new.run!
  end

  describe '#decline_reasons' do
    it "shows a shelter agency contact its audience-scoped reasons plus the shared 'Other'" do
      names = decision.decline_reasons(contact: shelter_agency_contact).map(&:first)

      expect(names).to include('Client has another housing option', 'Does not agree to services', 'Other')
      expect(names).not_to include('CORI', 'SORI')
    end

    it "shows an HSA contact its audience-scoped reasons plus the shared 'Other'" do
      names = decision.decline_reasons(contact: hsa_contact).map(&:first)

      expect(names).to include('CORI', 'SORI', 'Other')
      expect(names).not_to include('Client has another housing option', 'Does not agree to services')
    end

    it 'shows a contact who can act on behalf of match contacts every reason from both audiences' do
      names = decision.decline_reasons(contact: on_behalf_of_admin).map(&:first)

      expect(names).to include('Client has another housing option', 'CORI', 'Other')
    end
  end
end
