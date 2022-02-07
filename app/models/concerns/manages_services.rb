###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# required methods to get a model to work with the service_manager form widgets
# models should define their own has_many services
module ManagesServices

  def available_services
    Service.where.not id: services.select(:id)
  end

end
