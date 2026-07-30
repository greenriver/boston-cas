###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MatchDecisionStep, type: :model do
  let(:route) { create(:default_route) }

  it 'is valid with a route and decision_type' do
    step = build(:match_decision_step, route: route, decision_type: 'MatchDecisions::SomeStep')
    expect(step).to be_valid
  end

  it 'requires a decision_type' do
    step = build(:match_decision_step, route: route, decision_type: nil)
    expect(step).not_to be_valid
  end

  it 'rejects a duplicate decision_type on the same route' do
    create(:match_decision_step, route: route, decision_type: 'MatchDecisions::SomeStep')
    duplicate = build(:match_decision_step, route: route, decision_type: 'MatchDecisions::SomeStep')

    expect(duplicate).not_to be_valid
  end

  it 'allows the same decision_type on a different route' do
    other_route = create(:provider_route)
    create(:match_decision_step, route: route, decision_type: 'MatchDecisions::SomeStep')
    on_other_route = build(:match_decision_step, route: other_route, decision_type: 'MatchDecisions::SomeStep')

    expect(on_other_route).to be_valid
  end

  describe '#supports_declines?' do
    it 'is true for a decision class that includes MatchDecisions::AcceptsDeclineReason' do
      step = build(:match_decision_step, route: route, decision_type: 'MatchDecisions::MatchRecommendationDndStaff')
      expect(step.supports_declines?).to eq(true)
    end

    it 'is false for a decision class that does not include MatchDecisions::AcceptsDeclineReason' do
      step = build(:match_decision_step, route: route, decision_type: 'MatchDecisions::ConfirmMatchSuccessDndStaff')
      expect(step.supports_declines?).to eq(false)
    end

    it 'is false when decision_type does not resolve to a real class' do
      step = build(:match_decision_step, route: route, decision_type: 'MatchDecisions::NoSuchClass')
      expect(step.supports_declines?).to eq(false)
    end
  end

  describe '#display_name' do
    it "uses the decision class's own step_name, matching how the match page labels the current step" do
      step = build(:match_decision_step, route: route, decision_type: 'MatchDecisions::Thirteen::ThirteenClientMatch')
      expect(step.display_name).to eq('Client Match')
    end

    it 'falls back to a titleized class name when decision_type does not resolve to a real class' do
      step = build(:match_decision_step, route: route, decision_type: 'MatchDecisions::NoSuchClass')
      expect(step.display_name).to eq('No Such Class')
    end
  end
end
