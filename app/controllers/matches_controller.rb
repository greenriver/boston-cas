class MatchesController < ApplicationController
  include HasMatchAccessContext
  include Decisions
  include PjaxModalController

  skip_before_action :authenticate_user!
  before_action :require_match_access_context!
  before_action :find_match!, only: [:show]

  def show
    @client = @match.client
    @match_contacts = @match.match_contacts
    @current_contact = current_contact
    @opportunity = @match.opportunity
    current_decision = @match.current_decision
    @show_client_info = @match.show_client_info_to?(access_context.current_contact)
    @sub_program = @match.sub_program
    @program = @match.program
    sub_program_has_files = @sub_program.file_tags.exists?
    can_see_client_details = @client.has_full_housing_release? || can_view_all_clients?

    # Only show files if the user has access to the client details,
    # If the client has a full release on file or the user can see all clients
    # AND if the sub-program has file tags specified
    @show_files = @show_client_info && can_see_client_details && sub_program_has_files
    if @show_files
      t_t = Warehouse::Tagging.arel_table
      columns = {
        id: :id,
        updated_at: :updated_at,
        tag_id: t_t[:tag_id].as('tag_id').to_sql
      }
      available_files = Warehouse::File.for_client(@client.remote_id).
        joins(:taggings).
        where(taggings: {tag_id: @sub_program.file_tags.pluck(:tag_id)}).
        order(updated_at: :desc).
        pluck(*columns.values).map do |row|
          OpenStruct.new(Hash[columns.keys.zip(row)])
        end
      @files = @sub_program.file_tags.map do |tag|
        file = available_files.detect{|file| file.tag_id == tag.tag_id}
        if file
          [tag.name, file]
        else
          [tag.name, {}]
        end
      end.to_h
    end
    if current_decision.try :accessible_by?, current_contact
      @decision = current_decision
    end
    if params[:notification_id].present?
      @notification = @access_context.notification
      # load previously failed status sumission if available
      @update = session[:match_status_update][params[:notification_id]].presence rescue nil
      session[:match_status_update] = nil
    end
  end

  def history
    @match = match_scope.find(params[:match_id])
    @types = MatchRoutes::Base.match_steps
    render layout: false
  end

  def cant_edit_self?
    ! current_contact.user_can_edit_match_contacts? && hsa_can_edit_contacts?
  end
  helper_method :cant_edit_self?

  private

    def find_match!
      @match = match_scope.find(params[:id])
    end

end
