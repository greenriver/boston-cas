# Methods used to save the state of the universe during match creation
module MatchArchive
  # This module serves as a record of what is needed to get a model to work with the requirement manager

  extend ActiveSupport::Concern

  def prepare_for_archive
    attributes = if is_a?(OpportunityDetails::Base)
                   opportunity.attributes
                 else
                   self.attributes
    end
    return unless attributes.present?

    if respond_to?(:services) && services.any?
      attributes[:services] = services.map(&:prepare_for_archive)
    end
    if respond_to?(:requirements) && requirements.any?
      attributes[:requirements] = requirements.map(&:prepare_for_archive)
      attributes[:rules] = requirements.map { |m| { type: m.rule.type, id: m.id } }
    end
    attributes.reject { |k, _v| ['deleted_at', 'created_at', 'updated_at'].include? k }
  end
end
