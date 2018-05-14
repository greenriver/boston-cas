class DeidentifiedClientsController < ApplicationController
  before_action :require_can_enter_deidentified_clients! 
  before_action :require_can_manage_deidentified_clients!, only: [:edit, :update, :destroy]
  before_action :load_deidentified_client, only: [:edit, :update, :destroy]
  
  def index
    @deidentified_clients = deidentified_client_source.page(params[:page]).per(25)
  end

  def create
    clean_params = clean_params(deidentified_client_params)
    @deidentified_client = deidentified_client_source.create clean_params
    respond_with(@deidentified_client, location: deidentified_clients_path)
  end
  
  def new
    @deidentified_client = deidentified_client_source.new 
  end
  
  def edit
  end

  def update
    clean_params = clean_params(deidentified_client_params)
    @deidentified_client.update(clean_params)
    respond_with(@deidentified_client, location: deidentified_clients_path)
  end
  
  def destroy
    @deidentified_client.destroy
    respond_with(@deidentified_client, location: deidentified_clients_path)
  end
  
  def deidentified_client_source 
    DeidentifiedClient
  end
  
  private
    def deidentified_client_params
      params.require(:deidentified_client).permit(
        :client_identifier, 
        :assessment_score,
        :agency,
        :active_cohort_ids => [],
      )
    end
    
    def append_client_identifier dirty_params
      dirty_params[:last_name] = "Anonymous - #{dirty_params[:client_identifier]}"
      dirty_params[:first_name] = "Anonymous - #{dirty_params[:client_identifier]}"
      dirty_params
    end
    
    def reject_empty_cohort_ids dirty_params
      return dirty_params if dirty_params[:active_cohort_ids].blank?
      dirty_params[:active_cohort_ids].reject! { |r| r.blank? }
      dirty_params
    end
    
    def clean_params dirty_params
      append_client_identifier(reject_empty_cohort_ids(dirty_params))
    end
    
    def load_deidentified_client
      @deidentified_client = deidentified_client_source.find params[:id].to_i
    end
end
