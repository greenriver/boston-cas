###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class MatchNotesController < ApplicationController
  # controller to manage match notes
  include HasMatchAccessContext

  skip_before_action :authenticate_user!
  before_action :require_match_access_context!
  before_action :set_match!
  before_action :authorize_add_note!, :build_match_note, only: [:new, :create]
  before_action :set_match_note!, :authorize_note_editable!, only: [:edit, :update, :destroy]

  include AjaxModalRails::Controller

  def new
  end

  def create
    mn_params = match_note_params
    mn_params.delete(:admin_note) unless @match.can_create_administrative_note?(current_contact)
    @match_note.assign_attributes mn_params
    @match_note.contact = current_contact

    if match_note_params[:include_content] == '1' && mn_params[:contact_ids].delete_if(&:blank?).empty?
      @match_note.errors.add(:contact_ids, 'You must include contacts if you are sending the note via email')

      render(:new)
      return
    end
    if @match_note.save
      if @match.can_create_administrative_note?(current_contact) || current_user.can_send_notes_via_email?
        contact_ids = mn_params[:contact_ids].delete_if(&:blank?) if mn_params[:contact_ids].present?
        if contact_ids.present?
          contact_ids.each do |contact_id|
            include_content = match_note_params[:include_content]
            Notifications::NoteSent.create_for_match!(
              match_id: @match.id,
              contact_id: contact_id.to_i,
              note: @match_note.note,
              include_content: include_content,
            )
          end
        end
      end
      redirect_to(success_path)
      return
    else
      render(:new)
    end
  end

  def edit
  end

  def update
    mn_params = match_note_params
    mn_params.delete(:admin_note) unless @match.can_create_administrative_note?(current_contact)
    if @match_note.update mn_params
      redirect_to success_path
    else
      render :edit
    end
  end

  def destroy
    unless @match_note.note_editable_by?(current_contact)
      flash[:error] = 'You do not have permission to delete this note'
      redirect_to success_path and return
    end
    @match_note.note = nil
    @match_note.remove_note!
    redirect_to success_path
  end

  ################################
  ## New / Create Setup
  ################################

  private def set_match!
    @match = match_scope.find params[:match_id]
  end

  private def authorize_add_note!
    not_authorized unless @match.can_create_overall_note?(current_contact)
  end

  ################################
  ## Edit / Update / Destroy Setup
  ################################

  private def set_match_note!
    @match_note = MatchEvents::Base
      .where(match_id: @match.id)
      .find params[:id]
  end

  private def authorize_note_editable!
    not_authorized! unless @match_note.note_editable_by? current_contact
  end

  private def build_match_note
    @match_note = @match.note_events.build(include_content: @match.match_route.send_notes_by_default)
  end

  ################################
  ## Additional Utilities
  ################################

  private def success_path
    # TODO detect if we came from a specific decision and
    # go there instead
    access_context.match_path(@match)
  end

  private def match_note_params
    params.require(:match_note).
      permit(
        :note,
        :admin_note,
        :include_content,
        contact_ids: []
      )
  end

end
