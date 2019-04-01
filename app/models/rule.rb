class Rule < ActiveRecord::Base
  self.table_name = 'rules'
  include MatchArchive

  has_many :requirements
  has_many :services, through: :building_services

  acts_as_paranoid
  has_paper_trail

  def always_apply?
    false
  end

  def clients_that_fit(_scope, _requirement)
    raise "You need to define clients_that_fit on your Rule subclass #{self.class}."
  end

  def requirement_implied_by(_requirements)
    nil
    # Somewhat hard-coded logic (defined in subclasses) giving you a
    # requirement for this rule which a client will
    # definitely meet if they meet the given requirements, or no requirement.
  end

  def model_name
    ActiveModel::Name.new self, nil, 'rule'
  end

  def name_with_verb
    "#{verb} #{_(name)}"
  end

  def variable_requirement?
    false
  end

  def display_for_variable(_value)
    nil
  end
end

class RuleDatabaseStructureMissing < StandardError; end
