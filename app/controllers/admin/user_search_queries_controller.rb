###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Admin
  class UserSearchQueriesController < Admin::UsersController
    def show
      @search_query = ClientSearchQuery.find(params[:id])

      # If there's a new search query in params, handle it
      if params[:q].present? && params[:q] != @search_query.query_params[:q]
        handle_search_query
        return if performed? # Stop if we redirected
      end

      # Use the saved search query parameters
      params[:q] = @search_query.query_params[:q]

      # search
      if params[:q].present?
        @users = user_scope.text_search(params[:q])
        @inactive_users = User.inactive.text_search(params[:q])
      else
        @users = user_scope
        @inactive_users = User.inactive
      end

      # sort / paginate
      @users = @users
        .order(sort_column => sort_direction)
        .page(params[:page]).per(25)

      # count number of active/closed matches per user
      user_ids = @users.map(&:id)
      @active_matches = Contact.where(user_id: user_ids).
        joins(:matches).merge(ClientOpportunityMatch.active).
        group(:user_id).count
      @closed_matches = Contact.where(user_id: user_ids).
        joins(:matches).merge(ClientOpportunityMatch.closed).
        group(:user_id).count

      render template: 'admin/users/index'
    end
  end
end
