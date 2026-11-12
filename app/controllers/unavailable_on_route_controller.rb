###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class UnavailableOnRouteController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client
  before_action :require_client_editable!
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

  def require_client_editable!
    not_authorized! unless @client.editable_by?(current_user)
  end

  def flash_interpolation_options
    { resource_name: 'Match Route' }
  end
end
