###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module NonHmisClientsHelper

  def client_type
    controller_name.gsub('_clients', '')
  end

  def client_identified?
    client_type == 'identified'
  end

end
