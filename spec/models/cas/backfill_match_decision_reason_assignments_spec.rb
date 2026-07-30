###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

# REMOVE_AFTER_REASON_CHANGE: delete this spec alongside Cas::BackfillMatchDecisionReasonAssignments
# once every environment has run the backfill at least once (see comment on that class).

# Simulates a decision class in its pre-migration state: reasons hardcoded in Ruby,
# exactly the shape Cas::BackfillMatchDecisionReasonAssignments needs to read from.
class MatchDecisions::BackfillSpecStep < MatchDecisions::Base
  def step_decline_reasons(_contact = nil)
    ['Zebra Reason', 'Alpha Reason', 'Other']
  end

  def decline_reasons_not_other_requiring_explanation(_contact = nil)
    ['Alpha Reason']
  end

  def step_cancel_reasons
    ['Cancel Reason One']
  end

  def cancel_reasons_not_other_requiring_explanation
    []
  end
end

class MatchDecisions::BackfillSpecStepWithMissingReason < MatchDecisions::Base
  def step_decline_reasons(_contact = nil)
    ['Alpha Reason', 'Nonexistent Reason']
  end

  def decline_reasons_not_other_requiring_explanation(_contact = nil)
    []
  end

  def step_cancel_reasons
    []
  end
end

class MatchDecisions::BackfillSpecStepWithNoCancelOverride < MatchDecisions::Base
end

class MatchDecisions::BackfillSpecStepThatErrors < MatchDecisions::Base
  def step_decline_reasons(_contact = nil)
    match.shelter_agency_contacts
  end

  def step_cancel_reasons
    ['Cancel Reason One']
  end
end

RSpec.describe Cas::BackfillMatchDecisionReasonAssignments, type: :model do
  let(:route) { create(:default_route) }
  let(:backfill) { described_class.new }

  before do
    create(:match_decision_reason, name: 'Alpha Reason')
    create(:match_decision_reason, name: 'Zebra Reason')
    create(:match_decision_reason, name: 'Other')
    create(:match_decision_reason, name: 'Cancel Reason One')
  end

  describe '#backfill_step' do
    it 'creates a step registry row for the route and decision_type' do
      expect { backfill.backfill_step(route: route, decision_type: 'MatchDecisions::BackfillSpecStep') }.
        to change(MatchDecisionStep, :count).by(1)

      step = MatchDecisionStep.last
      expect(step.route).to eq(route)
      expect(step.decision_type).to eq('MatchDecisions::BackfillSpecStep')
    end

    it 'creates decline assignments in Other-last, alphabetical order, flagging reasons that require explanation' do
      backfill.backfill_step(route: route, decision_type: 'MatchDecisions::BackfillSpecStep')

      assignments = MatchDecisionReasonAssignment.where(route: route, decision_type: 'MatchDecisions::BackfillSpecStep', kind: 'decline').order(:position)

      expect(assignments.map { |a| a.match_decision_reason.name }).to eq(['Alpha Reason', 'Zebra Reason', 'Other'])
      expect(assignments.map(&:requires_explanation)).to eq([true, false, false])
    end

    it 'creates cancel assignments from step_cancel_reasons' do
      backfill.backfill_step(route: route, decision_type: 'MatchDecisions::BackfillSpecStep')

      assignments = MatchDecisionReasonAssignment.where(route: route, decision_type: 'MatchDecisions::BackfillSpecStep', kind: 'cancel')

      expect(assignments.map { |a| a.match_decision_reason.name }).to eq(['Cancel Reason One'])
    end

    it 'skips a reason name with no matching catalog entry instead of raising, while still creating the others' do
      expect do
        backfill.backfill_step(route: route, decision_type: 'MatchDecisions::BackfillSpecStepWithMissingReason')
      end.not_to raise_error

      assignments = MatchDecisionReasonAssignment.where(route: route, decision_type: 'MatchDecisions::BackfillSpecStepWithMissingReason', kind: 'decline')
      expect(assignments.map { |a| a.match_decision_reason.name }).to eq(['Alpha Reason'])
    end

    it "falls back to the original hardcoded cancel reason list for a class that never overrode step_cancel_reasons, instead of reading MatchDecisions::Base's now-DB-driven default" do
      create(:match_decision_reason, name: 'Match expired')

      backfill.backfill_step(route: route, decision_type: 'MatchDecisions::BackfillSpecStepWithNoCancelOverride')

      assignments = MatchDecisionReasonAssignment.where(route: route, decision_type: 'MatchDecisions::BackfillSpecStepWithNoCancelOverride', kind: 'cancel')
      expect(assignments.map { |a| a.match_decision_reason.name }).to contain_exactly('Match expired', 'Other')
    end

    it 'is idempotent when run twice' do
      backfill.backfill_step(route: route, decision_type: 'MatchDecisions::BackfillSpecStep')

      expect { backfill.backfill_step(route: route, decision_type: 'MatchDecisions::BackfillSpecStep') }.
        not_to change(MatchDecisionReasonAssignment, :count)
    end

    it 'logs and continues instead of raising when decline backfill errors for a step without a real match' do
      expect do
        backfill.backfill_step(route: route, decision_type: 'MatchDecisions::BackfillSpecStepThatErrors')
      end.not_to raise_error

      expect(MatchDecisionStep.find_by(route: route, decision_type: 'MatchDecisions::BackfillSpecStepThatErrors')).to be_present
      expect(MatchDecisionReasonAssignment.where(route: route, decision_type: 'MatchDecisions::BackfillSpecStepThatErrors', kind: 'decline')).to be_empty
    end

    it 'still backfills cancel reasons for a step even though its decline backfill errored' do
      backfill.backfill_step(route: route, decision_type: 'MatchDecisions::BackfillSpecStepThatErrors')

      assignments = MatchDecisionReasonAssignment.where(route: route, decision_type: 'MatchDecisions::BackfillSpecStepThatErrors', kind: 'cancel')
      expect(assignments.map { |a| a.match_decision_reason.name }).to eq(['Cancel Reason One'])
    end
  end
end
