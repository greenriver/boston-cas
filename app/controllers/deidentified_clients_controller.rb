class DeidentifiedClientsController < ApplicationController
  before_action :require_can_enter_deidentified_clients! 
  before_action :require_can_manage_deidentified_clients!, only: [:edit, :update, :destroy]
  before_action :load_deidentified_client, only: [:edit, :update, :destroy]
  
  def index
    @deidentified_clients = deidentified_client_source.page(params[:page]).per(25)
  end

  def create
    @deidentified_client = deidentified_client_source.create deidentified_client_params
    respond_with(@deidentified_client, location: deidentified_clients_path)
  end
  
  def new
    @deidentified_client = deidentified_client_source.new 
  end
  
  def deidentified_client_source 
    DeidentifiedClient
  end
  
  def edit
  end

  def update
    @deidentified_client.update(deidentified_client_params)
    respond_with(@deidentified_client, location: deidentified_clients_path)
  end
  
  def destroy
    @deidentified_client.destroy
    respond_with(@deidentified_client, location: deidentified_clients_path)
  end
  
  private
    def deidentified_client_params
      params.require(:deidentified_client).permit(
        :client_identifier, 
        :assessment_score,
        :agency
      )
    end
    
    def load_deidentified_client
      @deidentified_client = deidentified_client_source.find params[:id].to_i
    end
end
