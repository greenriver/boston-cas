###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class ClientMatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_can_view_all_matches!
  before_action :find_client!

  def index
    @matches = match_scope.
      references(:client).
      includes(:client).
      preload(:client, :opportunity, :decisions).
      page(params[:page]).per(25)
  end

  def active_tab
    'matches'
  end
  helper_method :active_tab

  private

  def match_scope
    ClientOpportunityMatch.
      accessible_by_user(current_user).
      open.
      active.
      where(client_id: @client.id)
  end

  def find_client!
    @client = client_scope.find(params[:client_id].to_i)
  end

  def client_scope
    Client.accessible_by_user(current_user)
  end

  def show_links_to_matches?
    true
  end
  helper_method :show_links_to_matches?
end
