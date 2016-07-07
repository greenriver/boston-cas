# Most things with inherited rules only inherit
# from services, so the common code is here
module InheritsRequirementsFromServices
  extend ActiveSupport::Concern
  
  def inherited_service_requirements_by_source
    {}.tap do |result|
      services.each do |service|
        result[service] = []
        service.requirements.each do |requirement|
          result[service] << requirement
        end
      end
    end
  end

  module ClassMethods
    def preload_inherited_service_requirements
      preload services: {requirements: :rules}
    end
  end

end

