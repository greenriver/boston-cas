###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module NonHmisAssessmentsHelper

  def client_type
    @non_hmis_client.type.downcase.gsub('client', '')
  end

end
