###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Requirement, type: :model do
  describe '#variable_requirement?' do
    it 'returns nil without raising when rule is nil' do
      req = described_class.new
      expect(req.rule).to be_nil
      expect { req.variable_requirement? }.not_to raise_error
      expect(req.variable_requirement?).to be_nil
    end

    it 'delegates to the rule when one is present' do
      rule = create(:active_in_cohort)
      req = described_class.new(rule: rule)
      expect(req.variable_requirement?).to eq(rule.variable_requirement?)
    end
  end

  describe 'variable validation' do
    let(:variable_rule) { create(:active_in_cohort) }
    let(:non_variable_rule) { create(:veteran) }

    it 'is invalid when variable is blank and rule requires a variable' do
      req = described_class.new(rule: variable_rule, variable: '')
      expect(req).not_to be_valid
      expect(req.errors[:variable]).to be_present
    end

    it 'is valid when variable is present and rule requires a variable' do
      req = described_class.new(rule: variable_rule, variable: '1,2')
      expect(req).to be_valid
    end

    it 'is valid when rule does not require a variable' do
      req = described_class.new(rule: non_variable_rule, variable: '')
      expect(req).to be_valid
    end

    it 'skips variable validation when rule is nil' do
      req = described_class.new(rule: nil, variable: '')
      req.valid?
      expect(req.errors[:variable]).to be_empty
    end
  end
end
