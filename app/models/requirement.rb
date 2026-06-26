###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Requirement < ApplicationRecord
  include MatchArchive
  belongs_to :rule
  belongs_to :requirer, polymorphic: true

  acts_as_paranoid
  has_paper_trail

  delegate :variable_requirement?, to: :rule, allow_nil: true
  validates_presence_of :variable, if: :variable_requirement?

  def clients_that_fit(scope, opportunity = nil)
    return scope unless rule.present?

    rule.clients_that_fit(scope, self, opportunity)
  end

  def compatible_with(requirements)
    if (requirement = rule.requirement_implied_by(requirements))
      requirement.positive == positive
    else
      true
    end
  end

  delegate :name, :name_with_verb, to: :rule, allow_nil: true, prefix: true
  delegate :alternate_name, to: :rule, allow_nil: true, prefix: true

  def name(on_unit: false)
    "#{positive? ? 'Must' : "Can't"} #{rule_text(on_unit: on_unit)}"
  end

  def rule_text(on_unit: false)
    if on_unit && rule_alternate_name.present?
      Translation.translate(rule_alternate_name)
    else
      "#{rule&.verb} #{Translation.translate(rule_name)}"
    end
  end

  def modal_verb
    positive? ? 'Must' : "Can't"
  end

  def modal_verb_class
    positive? ? 'primary' : 'warning'
  end

  def display_for_variable
    "(#{rule&.display_for_variable(variable)})" if variable.present?
  end

  def apply_to_match(match)
    return nil unless rule.present?

    rule.apply_to_match(match)
  end

  def associated_file_tags
    rule&.associated_file_tags(variable)
  end
end
