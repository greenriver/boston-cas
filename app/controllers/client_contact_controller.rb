###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class ClientContactController < ApplicationController
  include AjaxModalRails::Controller

  before_action :authenticate_user!
  before_action :set_client

  def edit
  end

  def update
    @client.update(contact_params)
    redirect_to(client_path(@client))
  end

  private def set_client
    @client = Client.find params[:client_id].to_i
  end

  private def contact_params
    params.require(:contact_info).
      permit(
        :email,
        :send_emails,
      )
  end
end
