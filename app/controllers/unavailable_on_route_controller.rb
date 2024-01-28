###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class UnavailableOnRouteController < ApplicationController
  before_action :authenticate_user!
  before_action :some_clients_editable!
  before_action :set_client
  before_action :set_unavailable_for

  def destroy
    if @unavailable_for.destroy
      flash[:notice] = "#{@client.name} is now available to match on the #{@unavailable_for.route&.title}"
    else
      flash[:error] = "Unable to make #{@client.name} available on the #{@unavailable_for.route&.title}"
    end
    redirect_to client_path(@client)
  end

  def client_scope
    Client.accessible_by_user(current_user)
  end

  def set_client
    @client = client_scope.find(params[:client_id].to_i)
  end

  def set_unavailable_for
    @unavailable_for = @client.unavailable_as_candidate_fors.find(params[:id].to_i)
  end

  def some_clients_editable!
    Client.editable_by(current_user).where(id: params[:client_id].to_i).exists?
  end

  def flash_interpolation_options
    { resource_name: 'Match Route' }
  end

end
