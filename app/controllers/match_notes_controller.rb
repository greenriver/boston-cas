class MatchNotesController < ApplicationController
  # controller to manage match notes
  include HasMatchAccessContext

  before_action :require_match_access_context!
  before_action :set_match!
  before_action :authorize_add_note!, :build_match_note, only: [:new, :create]
  before_action :set_match_note!, :authorize_note_editable!, only: [:edit, :update, :destroy]
  
  include PjaxModalController

  def new
  end
  
  def create
    @match_note.assign_attributes match_note_params
    @match_note.contact = current_contact
    if @match_note.save
      redirect_to success_path
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @match_note.update match_note_params
      redirect_to success_path
    else
      render :edit
    end
  end
  
  def destroy
    @match_note.note = nil
    @match_note.remove_note!
    redirect_to success_path
  end
  
  private
  
    ################################
    ## New / Create Setup
    ################################
    
    def set_match!
      @match = match_scope.find params[:match_id]
    end
    
    def authorize_add_note!
      not_authorized unless @match.can_create_overall_note?(current_contact)
    end
  
    ################################
    ## Edit / Update / Destroy Setup
    ################################
    
    def set_match_note!
      @match_note = MatchEvents::Base
        .where(match_id: @match.id)
        .find params[:id]
    end
    
    def authorize_note_editable!
      not_authorized! unless @match_note.note_editable_by? current_contact
    end
    
    def build_match_note
      @match_note = @match.note_events.build
    end

    ################################
    ## Additional Utilities
    ################################
    
    def success_path
      # TODO detect if we came from a specific decision and
      # go there instead
      access_context.match_path(@match)
    end
    
    def match_note_params
      params.require(:match_note).permit(:note)
    end
    
end
