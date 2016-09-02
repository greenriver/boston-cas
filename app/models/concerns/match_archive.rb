# Methods used to save the state of the universe during match creation
module MatchArchive
  # This module serves as a record of what is needed to get a model to work with the requirement manager
  
  extend ActiveSupport::Concern

  def prepare_for_archive   
    attributes = if self.is_a?(OpportunityDetails::Base)
      opportunity.attributes
    else
      self.attributes
    end
    return unless attributes.present?
    attributes.reject{|k,v| ['deleted_at', 'created_at', 'updated_at'].include? k}
  end
end
