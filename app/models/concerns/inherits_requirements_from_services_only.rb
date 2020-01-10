###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

# Most things with inherited rules only inherit
# from services, so the common code is here
module InheritsRequirementsFromServicesOnly
  extend ActiveSupport::Concern
  include InheritsRequirementsFromServices

  def inherited_requirements_by_source
    inherited_service_requirements_by_source
  end

  module ClassMethods
    def preload_inherited_requirements
      preload_inherited_service_requirements
    end
  end

end

