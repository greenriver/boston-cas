###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeidentifiedTcHat, type: :model do
  describe 'Fuzzed dates of birth' do
    let!(:assessment) { DeidentifiedTcHat.new }
    let!(:age_ranges) { assessment.send(:age_ranges) }
    it 'fall within the expected date range' do
      age_ranges.each do |k, v|
        # Skip nil keys which are used for the "unknown" age range
        next if k.nil?

        # Set the age of head of household age to the current key
        assessment.hoh_age = k.to_s
        # calculate the earliest and latest date of birth based on the age range
        earliest_dob = (Date.current - v[:range].last.years)
        latest_dob = (Date.current - v[:range].first.years)

        # Date of birth is being fuzzed. We are running this test 10,000 times
        # to get a probablily that we hit as many instances of the range as possible
        # and to account for the randomness of the fuzzing.
        # This is not a perfect test, but it should give us a good indication
        # that the fuzzing is working as expected.
        10_000.times do
          expect(assessment.date_of_birth).to be_between(earliest_dob, latest_dob)
        end
      end
    end
  end
end
