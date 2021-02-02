###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Admin
  class UsersController < ApplicationController
    # This controller is namespaced to prevent
    # route collision with Devise

    before_action :authenticate_user!
    before_action :require_can_edit_users!, except: [:stop_impersonating]
    before_action :set_user, only: [:edit, :confirm, :update, :destroy, :impersonate]
    before_action :require_can_become_other_users!, only: [:impersonate]

    helper_method :sort_column, :sort_direction

    def index
      # search
      @users = if params[:q].present?
        user_scope.text_search(params[:q])
      else
        user_scope
      end

      # sort / paginate
      @users = @users
        .order(sort_column => sort_direction)
        .page(params[:page]).per(25)
      @inactive_users = User.inactive
    end

    def edit
      # check for existing contact with the same email
      contact = Contact.where("LOWER(email) = ?", @user.email.downcase)&.first
      if ! @user.contact
        if contact.present?
          @user.contact = contact
        else
          @user.build_contact
        end
      end
      @client_contacts = Client.where(id: ClientContact.where(contact_id: @user.contact).select(:client_id))
      @subgrantee_contacts = Subgrantee.where(id: SubgranteeContact.where(contact_id: @user.contact).select(:subgrantee_id))
      @building_contacts = Building.where(id: BuildingContact.where(contact_id: @user.contact).select(:building_id))
      @opportunity_contacts = Opportunity.where(id: OpportunityContact.where(contact_id: @user.contact).select(:opportunity_id))
    end

    def confirm
      if ! adding_admin?
        update
      end
    end

    def impersonate
      become = User.find(params[:become_id].to_i)
      impersonate_user(become)
      redirect_to root_path
    end

    def stop_impersonating
      stop_impersonating_user
      redirect_to root_path
    end

    def update
      if adding_admin?
        if ! current_user.valid_password?(confirmation_params[:confirmation_password])
          flash[:error] = "User not updated. Incorrect password"
          render :confirm
          return
        end
      end

      @user.assign_attributes(user_params)
      if @user.save
        redirect_to({action: :index}, notice: 'User updated')
      else
        flash[:error] = 'Please review the form problems below'
        render :edit
      end
    end

    def destroy
      @user.update(active: false)
      redirect_to({action: :index}, notice: 'User deactivated')
    end

    def reactivate
      @user = User.inactive.find(params[:id].to_i)
      pass = Devise.friendly_token(50)
      @user.update(active: true, password: pass, password_confirmation: pass)
      @user.send_reset_password_instructions
      redirect_to({action: :index}, notice: "User #{@user.name} re-activated")

    end

    private

      def adding_admin?
        existing_roles = @user.user_roles
        existing_roles.each do |role|
          # User is already an admin, so we aren't adding anything
          return false if role.administrative?
        end

        assigned_roles = user_params[:role_ids] || []
        added_role_ids = assigned_roles - existing_roles.pluck(:role_id)
        added_role_ids.reject { |id| id.empty? }.each do |id|
          role = Role.find(id.to_i)
          if role.administrative?
            @admin_role_name = role.role_name
            return true
          end
        end
        return false
      end

      def user_scope
        User.active.order(last_name: :asc, first_name: :asc)
      end

      def user_params
        params.require(:user).permit(
          :first_name,
          :last_name,
          :email,
          :receive_initial_notification,
          :agency_id,
          role_ids: [],
          contact_attributes: [:id, :first_name, :last_name, :phone, :email, :role],
          requirements_attributes: [:id, :rule_id, :positive, :variable, :_destroy]
        )
      end

      def confirmation_params
        params.require(:user).permit(
          :confirmation_password
        )
      end

      def sort_column
        user_scope.column_names.include?(params[:sort]) ? params[:sort] : 'last_name'
      end

      def sort_direction
        %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
      end

      def set_user
        @user = user_scope.find params[:id].to_i
      end

  end
end
