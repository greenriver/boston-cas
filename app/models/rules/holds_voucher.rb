###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Rules::HoldsVoucher < Rule
  def clients_that_fit(scope, requirement, opportunity)
    # Only mobile vouchers can match
    returns false if SubProgram.have_buildings.include?(opportunity.voucher.sub_program.program_type)

    if Client.column_names.include?(:holds_voucher_on.to_s)
      if requirement.positive
        scope.where.not(holds_voucher_on: nil)
      else
        scope.where(holds_voucher_on: nil)
      end
    else
      raise RuleDatabaseStructureMissing.new("clients.holds_voucher_on missing. Cannot check clients against #{self.class}.")
    end
  end


  def apply_to_match(match)
    # Don't try and copy contacts unless the client holds a voucher
    return unless match.client.holds_voucher_on.present?

    # Find the first active match that holds a voucher
    source_match = match.client.active_matches.detect do |candidate|
      candidate.current_decision.holds_voucher?
    end
    return unless source_match.present?

    # Copy the relevant contacts from the source match
    source_match.dnd_staff_contacts.each do |contact|
      match.assign_match_role_to_contact(:dnd_staff, contact)
    end
    source_match.housing_subsidy_admin_contacts.each do |contact|
      match.assign_match_role_to_contact(:housing_subsidy_admin, contact)
    end
    source_match.shelter_agency_contacts.each do |contact|
      match.assign_match_role_to_contact(:shelter_agency, contact)
    end
    source_match.client_contacts.each do |contact|
      match.assign_match_role_to_contact(:client, contact)
    end
  end
end
