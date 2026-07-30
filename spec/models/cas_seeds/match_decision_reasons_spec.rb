###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CasSeeds::MatchDecisionReasons do
  describe '#run!' do
    it 'creates catalog reasons from db/seeds/match_decision_reasons.csv with their referral_result' do
      described_class.new.run!

      other = MatchDecisionReasons::Base.find_by(name: 'Other')
      cori = MatchDecisionReasons::Base.find_by(name: 'CORI')

      expect(other).to be_present
      expect(other.referral_result).to be_nil
      expect(cori.referral_result).to eq(MatchDecisionReasons::Base::PROVIDER_REJECTED)
    end

    it 'is idempotent' do
      described_class.new.run!
      count_after_first_run = MatchDecisionReasons::Base.count

      described_class.new.run!

      expect(MatchDecisionReasons::Base.count).to eq(count_after_first_run)
    end
  end
end
