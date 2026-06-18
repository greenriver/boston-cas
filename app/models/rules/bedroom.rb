###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Rules::Bedroom < Rule
  def description
    'Matches clients who require at least the number of bedrooms specified in "Minimum number of bedrooms required" as indicated on an assessment.'
  end

  # supports markdown
  def selection_note(context: nil)
    return unless context == :voucher

    # Note for the voucher requirements page, which appears to be have in the reverse of the expected logic.
    note = <<~NOTE
      ### Note
      If this voucher is attached to a 2 bedroom unit, to match a client who requires 2 or more bedrooms, choose "Can't have minimum number of bedrooms" with "One" selected as the number of bedrooms.

      For a 3 bedroom unit, choose "Can't have minimum number of bedrooms" with "Two" selected as the number of bedrooms.
    NOTE
    Translation.translate(note)
  end

  def variable_requirement?
    true
  end

  def available_number_of_bedrooms
    [
      [1, 'One'],
      [2, 'Two'],
      [3, 'Three'],
      [4, 'Four'],
      [5, 'Five'],
    ]
  end

  def display_for_variable value
    available_number_of_bedrooms.to_h.try(:[], value.to_i) || value
  end

  def clients_that_fit(scope, requirement, _opportunity)
    raise RuleDatabaseStructureMissing.new("clients.required_number_of_bedrooms missing. Cannot check clients against #{self.class}.") unless Client.column_names.include?(:required_number_of_bedrooms.to_s)

    if requirement.positive
      scope.where(c_t[:required_number_of_bedrooms].lteq(requirement.variable))
    else
      scope.where(c_t[:required_number_of_bedrooms].gt(requirement.variable))
    end
  end
end
