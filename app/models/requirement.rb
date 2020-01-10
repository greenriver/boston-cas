###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Requirement < ActiveRecord::Base
  include MatchArchive
  belongs_to :rule
  belongs_to :requirer, polymorphic: true

  acts_as_paranoid
  has_paper_trail

  def clients_that_fit(scope)
    rule.clients_that_fit(scope, self)
  end

  def compatible_with(requirements)
    if requirement = rule.requirement_implied_by(requirements)
      requirement.positive == positive
    else
      true
    end
  end

  delegate :name, :name_with_verb, to: :rule, allow_nil: true, prefix: true

  def name
    "#{positive? ? 'Must' : "Can't" } #{rule.verb} #{_(rule_name)}"
  end

  def display_for_variable
    if variable.present?
      "(#{rule.display_for_variable(variable)})"
    end
  end

end
