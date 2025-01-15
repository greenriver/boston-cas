###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchPrioritization
  class RrhAndTh < Base
    def self.title
      'RRH and TH - Boston'
    end

    # (1) Prioritization will FIRST look for households who HAVE at LEAST >0 day of unsheltered homelessness (HMIS or Family Pathways reported) OR on Housing Needs Enrollment indicating a family member is experiencing Domestic Violence (Yes on Entry) AND answer YES to ineligible for State Emergency Assistance Question (5a)
    # OF this group, prioritize by total length of time homeless from Pathways
    # (2) IF no clients meet the requirements in (1) THEN look for clients who are ENROLLED in Emergency Shelter OR Transitional Housing AND answer YES to ineligible for State Emergency Assistance Question (5a)
    # OF this group, prioritize by total length of time homeless from Pathways
    # (3) IF no clients meet requirements of (1) or (2), then prioritize by length of time homeless
    # (4) Tie Breaker Date
    def self.prioritization_for_clients(scope, match_route:) # rubocop:disable Lint/UnusedMethodArgument
      # case statement
      # if total_homeless_nights_unsheltered > 0
      # then 3
      # if disqualified_for_state_assistance && household_dv_survivor
      # then 3
      # if (enrolled_in_es OR enrolled_in_th) && disqualified_for_state_assistance
      # then 2
      # else
      # 1
      unsheltered_nights = c_t[:total_homeless_nights_unsheltered].gt(0)
      service_need = c_t[:disqualified_for_state_assistance].eq(true).and(c_t[:household_dv_survivor].eq(true))
      enrolled = c_t[:disqualified_for_state_assistance].eq(true).and(c_t[:enrolled_in_es].eq(true).or(c_t[:enrolled_in_th].eq(true)))

      # Primary sort desc
      # Secondary sort days_homeless_in_last_three_years desc
      # Tertiary sort tie_breaker_date
      primary_order = Arel::Nodes::Case.new.
        when(unsheltered_nights).then(3). # Prioritization will FIRST look for households who HAVE at LEAST >0 day of unsheltered homelessness
        when(service_need).then(3). # on Housing Needs Enrollment indicating a family member is experiencing Domestic Violence (Yes on Entry) AND answer YES to ineligible for State Emergency Assistance Question
        when(enrolled).then(2). # THEN look for clients who are ENROLLED in Emergency Shelter OR Transitional Housing AND answer YES to ineligible for State Emergency Assistance Question
        else(1).desc
      secondary_order = c_t[:days_homeless_in_last_three_years].desc.nulls_last
      tertiary_order = c_t[:tie_breaker_date].asc.nulls_last

      scope.order(primary_order, secondary_order, tertiary_order)
    end

    def self.supporting_column_names
      [
        :total_homeless_nights_unsheltered,
        :disqualified_for_state_assistance,
        :household_dv_survivor,
        :days_homeless_in_last_three_years,
        :tie_breaker_date,
      ]
    end

    def self.supporting_data_columns
      {
        'Nights unsheltered' => lambda(&:total_homeless_nights_unsheltered),
        'Ineligible for state emergency assistance' => lambda(&:disqualified_for_state_assistance),
        'Household DV survivor' => lambda(&:household_dv_survivor),
        'Days homeless in the last 3 years' => lambda(&:days_homeless_in_last_three_years),
        'Tie Breaker Date' => lambda(&:tie_breaker_date),
      }
    end
  end
end
