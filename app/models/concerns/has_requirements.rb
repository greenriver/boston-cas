# The unwitting consequence of decentralizing the network of requirements was
# that I had to put code in place to avoid inifinitely looping (in two
# different ways). There are a few different ways this code can be improved.
module HasRequirements
  # This module serves as a record of what is needed to get a model to work with the requirement manager

  extend ActiveSupport::Concern

  included do
    has_many :requirements, as: :requirer
    accepts_nested_attributes_for :requirements, allow_destroy: true
  end

  def available_rules
    Rule.where.not(id: requirements.select(:rule_id)).order(:name)
  end

  class ClassMethodLoopException < StandardError; end
end
