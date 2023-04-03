###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class RulesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_can_view_rule_list!
  before_action :require_can_edit_rule_list!, only: [:update, :destroy, :create]
  before_action :set_rule, only: [:confirm_destroy, :destroy]

  helper_method :sort_column, :sort_direction

  ## actions

  def index
    @query = params[:q]
    base_scope =
      rule_scope.
      with_deleted.
      preload(requirements: :requirer).
      page(params[:page]).
      per(250).
      order(sort_column => sort_direction)
    if params[:q]
      rule_arel = Rule.arel_table
      @rules = base_scope.where(rule_arel[:name].matches(query_string))
    else
      @rules = base_scope
    end
  end

  def restore
    @rule = rule_scope.with_deleted.find(params[:id])
    if @rule.restore
      redirect_to rules_path
    else
      flash[:alert] = 'Rule could not be restored.'
      render :index
    end
  end

  def confirm_destroy
    if @rule.requirements.any?
      render :rule_in_use
    end
  end

  def destroy
    if @rule.destroy
      redirect_to rules_path
    else
      flash[:alert] = 'Rule could not be deleted.'
      render :index
    end
  end

  ## end actions

  protected
    def rule_scope
      Rule
    end

    def set_rule
      @rule = rule_scope.find(params[:id])
    end

    def sort_column
      Rule.column_names.include?(params[:sort]) ? params[:sort] : 'name'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def query_string
      "%#{@query}%"
    end
end
