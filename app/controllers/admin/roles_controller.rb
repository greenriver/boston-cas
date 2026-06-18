###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module Admin
  class RolesController < ApplicationController
    before_action :require_can_edit_roles!
    before_action :set_role, only: [:edit, :update, :destroy]

    def index
      @roles = role_scope.order(name: :asc)
    end

    def new
      @role = Role.new
    end

    def edit
      @users = User.joins(:roles).merge(Role.where(id: @role.id))
    end

    def update
      @role.update(role_params)
      respond_to do |format|
        format.html do
          respond_with(@role, location: admin_roles_path)
        end
        format.json do
          render(json: nil, status: :ok) if @role.errors.none?
          return
        end
      end
    end

    def create
      @role = Role.create(role_params)
      respond_with(@role, location: admin_roles_path)
    end

    def destroy
      @role.destroy
      redirect_to({ action: :index }, notice: 'Role deleted')
    end

    def batch_update
      Role.transaction do
        batch_params.each do |id, permitted|
          role_scope.find(id.to_i).update!(permitted)
        end
      end
      redirect_to admin_roles_path, notice: 'Roles updated successfully.'
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
      redirect_to admin_roles_path, alert: "Update failed: #{e.message}"
    end

    private

    def set_role
      @role = role_scope.find(params[:id].to_i)
    end

    def role_scope
      Role.all
    end

    def role_params
      params.require(:role).
        permit(
          :name,
          Role.permissions,
        )
    end

    def batch_params
      permitted_perms = Role.permissions.map(&:to_s)
      result = {}
      (params[:role] || {}).each do |role_id, role_attrs|
        next unless role_attrs.is_a?(ActionController::Parameters)

        result[role_id] = role_attrs.permit(*permitted_perms)
      end
      result
    end
  end
end
