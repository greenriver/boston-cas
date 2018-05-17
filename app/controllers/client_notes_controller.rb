class ClientNotesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_can_edit_all_clients!
  before_action :set_client_id
  before_action :set_client_note_id, only: [:destroy]

  def create 
    @client_note = ClientNote.create(client_note_params.merge({
      user_id: current_user.id,
      client_id: @client_id
    }))
    redirect_to client_path(@client_id)
  end
  
  def destroy
    @client_note = ClientNote.find(@client_note_id)
    begin
      if @client_note.user_can_destroy?(current_user) 
        @client_note.destroy!
        flash[:notice] = "Note was successfully deleted."
      else 
        raise "You are not authorized to delete this note."
      end
    rescue Exception => e
      flash[:error] = "Note could not be deleted."
    end
    redirect_to client_path(@client_id)
  end
  
  private
    def client_note_params
      params.require(:client_note).permit(
        :note, 
      )
    end
    
    def set_client_id
      @client_id = params.require(:client_id)
    end
    
    def set_client_note_id
      @client_note_id = params.require(:id)
    end
    
end
