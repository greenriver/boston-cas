###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'csv'

module CasSeeds
  class MatchDecisionReasons
    def run!
      csv_text = File.read(Rails.root.join('db', 'seeds', 'match_decision_reasons.csv'))
      CSV.parse(csv_text, headers: true).each do |row|
        referral_result = row['referral_result'].presence&.to_i
        reason = ::MatchDecisionReasons::Base.where(name: row['name']).first_or_create!
        reason.update(referral_result: referral_result)
      end
    end
  end
end
