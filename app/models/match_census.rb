###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class MatchCensus < ActiveRecord::Base
  belongs_to :opportunity
  belongs_to :match, class_name: 'ClientOpportunityMatch', required: false

  def self.populate!
    # Add all opportunities that do not have active matches
    Opportunity.with_voucher.available_candidate.distinct.find_each do |opp|
      populate_from_opportunity!(opp)
    end
    # Add all opportunities with active matches
    Opportunity.with_voucher.joins(:active_matches).distinct.find_each do |opp|
      populate_from_opportunity!(opp)
    end
  end

  def self.populate_from_opportunity! opp
    self.transaction do
      # Clear any existing data for this opportunity on this day, and rebuild
      where(opportunity_id: opp.id, date: Date.current).delete_all
      clients_for_route = Client.available_for_matching(opp.match_route)
      match_prioritization = opp.match_route.match_prioritization
      # IDs of prioritized clients who match this opportunity, prioritized by route configuration
      available_client_ids = opp.matching_clients(clients_for_route).map do |client|
        {
          client_id: client.id,
          score: match_prioritization.client_prioritization_summary(client, opp.match_route),
        }
      end
      sub_program = opp.sub_program
      program = sub_program.program
      active_matches = opp.active_matches.to_a
      if active_matches.any?
        active_matches.each do |match|
          prioritization_value = nil
          if match.client.present?
            prioritization_value = match_prioritization.client_prioritization_summary(match.client, opp.match_route)
          end

          create!(
            date: Date.current,
            opportunity_id: opp.id,
            match_id: match.id,
            program_name: program.name,
            sub_program_name: sub_program.name,
            match_prioritization_id: match_prioritization.id,
            prioritization_method_used: match_prioritization.title,
            prioritized_client_ids: available_client_ids,
            active_client_id: match.client_id,
            active_client_prioritization_value: prioritization_value,
            requirements: opp.requirements_for_archive,

          )
        end
      else
        create!(
          date: Date.current,
          opportunity_id: opp.id,
          program_name: program.name,
          sub_program_name: sub_program.name,
          prioritized_client_ids: available_client_ids,
          requirements: opp.requirements_for_archive,
          prioritization_method_used: match_prioritization.title,
          match_prioritization_id: match_prioritization.id,
        )
      end
    end
  end
end
