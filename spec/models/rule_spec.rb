###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rule, type: :model do
  describe '#variable_label' do
    it 'returns a human label for rules that have one' do
      rule = create(:active_in_cohort)
      expect(rule.variable_label).to eq('Cohort')
    end

    it 'returns nil for rules without a variable label' do
      rule = create(:veteran)
      expect(rule.variable_label).to be_nil
    end
  end
end
