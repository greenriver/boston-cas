###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Admin
  class WeightingRulesController < ApplicationController
    before_action :require_can_manage_config!
    before_action :load_match_route
    before_action :load_weighting_rule, only: [:edit, :update, :destroy]

    def index
    end

    def new
      # NOTE: this will create a rule regardless of if you add requirements
      # because the requirements editor requires the rule to be persisted
      @weighting_rule = @route.weighting_rules.create
      redirect_to edit_admin_match_route_weighting_rule_path(@route, @weighting_rule)
    end

    def edit
    end

    def update
      @weighting_rule.update(rule_params)
      @weighting_rule.reset_similar_counts!
      respond_with(@weighting_rule, location: edit_admin_match_route_path(@route))
    end

    def destroy
      @weighting_rule.reset_similar_counts!
      @weighting_rule.destroy
      respond_with(@weighting_rule, location: edit_admin_match_route_path(@route))
    end

    def load_match_route
      @route = MatchRoutes::Base.find params[:match_route_id].to_i
    end

    def load_weighting_rule
      @weighting_rule = @route.weighting_rules.find(params[:id].to_i)
    end

    private def rule_params
      return {} unless params[:weighting_rule].present?

      params.require(:weighting_rule).
        permit(
          requirements_attributes: [:id, :rule_id, :positive, :variable, :_destroy],
        )
    end
  end
end
