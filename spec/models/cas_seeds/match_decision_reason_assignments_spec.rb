###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CasSeeds::MatchDecisionReasonAssignments do
  before do
    CasSeeds::MatchDecisionReasons.new.run!
  end

  describe '#run!' do
    it 'ensures a match decision step exists for every route/step from MatchRoutes::*#match_steps' do
      described_class.new.run!

      route = MatchRoutes::Default.first
      expect(MatchDecisionStep.exists?(route: route, decision_type: 'MatchDecisions::MatchRecommendationDndStaff')).to be true
    end

    it 'creates reason assignments from db/seeds/match_decision_reason_assignments.csv' do
      described_class.new.run!

      route = MatchRoutes::Default.first
      names = MatchDecisionReasonAssignment.resolve_for(route: route, decision_type: 'MatchDecisions::MatchRecommendationDndStaff', kind: 'decline').map { |a| a.match_decision_reason.name }

      expect(names).to include('Client has another housing option', 'Other')
    end

    it "seeds MatchDecisions::ApproveMatchHousingSubsidyAdmin's audience-tagged decline reasons" do
      described_class.new.run!

      assignments = MatchDecisionReasonAssignment.where(decision_type: 'MatchDecisions::ApproveMatchHousingSubsidyAdmin', kind: 'decline')

      expect(assignments.pluck(:audience)).to include('shelter_agency_contacts', 'housing_subsidy_admin_contacts')
    end

    it 'assigns each audience-tagged reason to its own audience, not the other' do
      described_class.new.run!

      shelter_agency_reason = MatchDecisionReasons::Base.find_by(name: 'Client has another housing option')
      hsa_reason = MatchDecisionReasons::Base.find_by(name: 'CORI')

      shelter_agency_assignment = MatchDecisionReasonAssignment.find_by(decision_type: 'MatchDecisions::ApproveMatchHousingSubsidyAdmin', match_decision_reason: shelter_agency_reason)
      hsa_assignment = MatchDecisionReasonAssignment.find_by(decision_type: 'MatchDecisions::ApproveMatchHousingSubsidyAdmin', match_decision_reason: hsa_reason)

      expect(shelter_agency_assignment.audience).to eq('shelter_agency_contacts')
      expect(hsa_assignment.audience).to eq('housing_subsidy_admin_contacts')
    end

    it 'seeds every resolvable row from the assignments CSV, dropping none silently' do
      described_class.new.run!

      csv_row_count = CSV.read(Rails.root.join('db', 'seeds', 'match_decision_reason_assignments.csv'), headers: true).size
      approve_match_hsa_count = CasSeeds::MatchDecisionReasonAssignments::APPROVE_MATCH_HOUSING_SUBSIDY_ADMIN_SHELTER_AGENCY_ONLY_REASONS.size +
        CasSeeds::MatchDecisionReasonAssignments::APPROVE_MATCH_HOUSING_SUBSIDY_ADMIN_HSA_ONLY_REASONS.size + 1

      expect(MatchDecisionReasonAssignment.count).to eq(csv_row_count + approve_match_hsa_count)
    end

    it 'is idempotent' do
      described_class.new.run!
      count_after_first_run = MatchDecisionReasonAssignment.count

      described_class.new.run!

      expect(MatchDecisionReasonAssignment.count).to eq(count_after_first_run)
    end
  end
end
