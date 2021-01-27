###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class AssociatedContactsController < ApplicationController
  # Abstract class for managing contacts associated with a record,
  # e.g. ClientContactsController

  before_action :authenticate_user!
  before_action :set_contact_owner!
  before_action :set_contact_join_model!, only: [:edit, :update, :destroy]
  before_action :require_can_view_contacts!
  before_action :require_can_edit_contacts!, only: [:update, :create, :destroy]

  def index

    @contact_join_models = if params[:q].present?
      contact_join_model_source.text_search(params[:q])
    else
      contact_join_model_source
    end
    @contact_join_models = @contact_join_models
      .with_deleted
      .includes(:contact)
      .all
      .page(params[:page])
      .per(15)
  end

  def new
    @contact_join_model = contact_join_model_source.new
    @contact_join_model.build_contact
    set_available_contacts
    @available_contacts = if params[:q].present?
      @available_contacts.text_search(params[:q])
    else
      @available_contacts
    end
  end

  def create
    @contact_join_model = contact_join_model_source.new contact_join_model_params
    if @contact_join_model.save
      redirect_to({action: :index}, notice: "New contact added to #{@contact_owner.class.to_s.humanize}")
    else
      flash[:error] = 'Please review the form problems below.'
      set_available_contacts
      render :new
    end
  end

  def edit
  end

  def update
    if @contact_join_model.update contact_join_model_params
      redirect_to({action: :index}, notice: "Contact updated")
    else
      flash[:error] = 'Please review the form problems below'
      render :edit
    end
  end

  def destroy
    @contact_join_model = contact_join_model_source.find params[:id]
    @contact_join_model.destroy
    redirect_to({action: :index}, notice: "Contact removed")
  end

  def restore
    contact_join_model_source.restore(params[:id])
    redirect_to( {action: :index}, notice: "Contact restored")
  end

  private

    def set_contact_owner!
      @contact_owner = contact_owner_source.find(params["#{contact_owner_source.model_name.singular_route_key}_id"])
    end

    def set_contact_join_model!
      @contact_join_model = contact_join_model_source.find params[:id]
    end

    def contact_owner_source
      raise 'Abstract method'
    end

    def contact_join_model_source
      raise 'Abstract method'
    end

    def build_new_building_contact
      @contact_join_model = contact_join_model_source.new contact_join_model_params
      @contact_join_model.build_contact unless @contact_join_model.contact
    end

    def set_available_contacts
      @available_contacts = Contact
        .where.not(id: contact_join_model_source.select(:contact_id))
        .page(params[:page])
        .per(5)
    end

    def contact_join_model_params
      params.require(join_model_class.model_name.param_key).permit(
        :contact_id,
        contact_attributes: [
          :id,
          :first_name,
          :last_name,
          :role,
          :email,
          :phone,
          :cell_phone
        ]
      )
    end

    def join_model_class
      raise "Abstract Method"
    end
end
