###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeightingRule, type: :model do
  # The :program factory uses MatchRoutes::Default.first, so a WeightingRule on
  # that route applies to the sub-program (match_route is through the program).
  let(:route) { MatchRoutes::Default.first }
  let(:program) { create(:program) }
  let(:sub_program) do
    create(:sub_program, program: program, program_type: 'Project-Based', building: create(:building))
  end

  # Build a weighting rule on the shared route with a single requirement so we can
  # assert both which rule is picked and that its requirements are copied out.
  def weighting_rule_with_requirement(applied_to: 0)
    wr = create(:weighting_rule, route: route, applied_to: applied_to)
    Requirement.create!(requirer: wr, rule: create(:homeless))
    wr
  end

  describe '.next_for' do
    it 'returns the rule with the lowest applied_to count' do
      heavy = create(:weighting_rule, route: route, applied_to: 5)
      light = create(:weighting_rule, route: route, applied_to: 1)

      expect(described_class.next_for(route.id)).to eq(light)
      expect(described_class.next_for(route.id)).not_to eq(heavy)
    end
  end

  describe '.lightest_first' do
    it 'orders rules by applied_to ascending' do
      a = create(:weighting_rule, route: route, applied_to: 3)
      b = create(:weighting_rule, route: route, applied_to: 0)
      c = create(:weighting_rule, route: route, applied_to: 7)

      expect(described_class.lightest_first.to_a).to eq([b, a, c])
    end
  end

  describe '#increment!' do
    it 'increases applied_to by one and persists it' do
      rule = create(:weighting_rule, route: route, applied_to: 2)

      expect { rule.increment! }.to change { rule.reload.applied_to }.from(2).to(3)
    end
  end

  describe '.requirements_and_increment!' do
    it 'returns nil and increments nothing when the route has no weighting rules' do
      expect(route.weighting_rules).to be_empty

      expect(described_class.requirements_and_increment!(sub_program)).to be_nil
    end

    it 'returns nil and increments nothing when the sub-program has weighting rules disabled' do
      rule = weighting_rule_with_requirement
      sub_program.update!(weighting_rules_active: false)

      expect(described_class.requirements_and_increment!(sub_program)).to be_nil
      expect(rule.reload.applied_to).to eq(0)
    end

    it 'increments the lightest rule and returns unpersisted copies of its requirements' do
      heavy = weighting_rule_with_requirement(applied_to: 5)
      light = weighting_rule_with_requirement(applied_to: 1)

      requirements = described_class.requirements_and_increment!(sub_program)

      # The lighter rule is chosen and incremented; the heavier rule is untouched.
      expect(light.reload.applied_to).to eq(2)
      expect(heavy.reload.applied_to).to eq(5)

      # Copies (not the originals) are returned so the caller can attach them to a
      # new Voucher without moving or persisting the rule's own requirements.
      expect(requirements).to all(be_a(Requirement))
      expect(requirements).to all(be_new_record)
      expect(requirements.map(&:rule_id)).to eq(light.requirements.map(&:rule_id))
    end

    it 'distributes evenly across equally-weighted rules over repeated calls (round-robin)' do
      a = weighting_rule_with_requirement(applied_to: 0)
      b = weighting_rule_with_requirement(applied_to: 0)

      4.times { described_class.requirements_and_increment!(sub_program) }

      # Always picking the strictly-lightest rule balances usage: four applications
      # split two-and-two. (Picking the heaviest instead would pile all four onto one.)
      expect(a.reload.applied_to).to eq(2)
      expect(b.reload.applied_to).to eq(2)
    end
  end
end
