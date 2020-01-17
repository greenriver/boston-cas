###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class MatchProgressUpdateNotesController < ApplicationController
  include HasMatchAccessContext
  include PjaxModalController

  skip_before_action :authenticate_user!
  before_action :require_match_access_context!
  before_action :set_match!
  before_action :set_update!
  before_action :authorize_note_editable!

  def edit
  end

  def update
    if @update.update(update_params)
      redirect_to match_path(@match)
    else
      render :edit
    end
  end

  def destroy
    unless @update.note_editable_by?(current_contact)
      flash[:error] = 'You do not have permission to delete this note'
      redirect_to redirect_to match_path(@match) and return
    end
    if @update.response_requires_note?
      flash[:error] = 'This note cannot be deleted as it is required by the kind of response'
      redirect_to match_path(@match) and return
    end
    # The note is not a separate object, so we nil out the note field in the update
    @update.note = nil
    @update.save!
    redirect_to match_path(@match)
  end

  private

  def set_match!
    @match = match_scope.find params[:match_id].to_i
  end

  def set_update!
    @update = MatchProgressUpdates::Base.find params[:id].to_i
  end

  def authorize_note_editable!
    not_authorized! unless @update.note_editable_by? current_contact
  end

  def update_params
    params.require(:update).
      permit(:note)
  end

end
