###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchShow
  extend ActiveSupport::Concern

  def set_update
    @update = MatchProgressUpdates::Anyone.new(
      match_id: @match.id,
      contact_id: current_contact.id,
      notification_id: params[:notification_id]&.to_i,
      decision_id: @decision&.id,
      submitted_at: Time.current,
    )
  end

  def prep_for_show
    @client = @match.client
    @match_contacts = @match.match_contacts
    @current_contact = current_contact
    @opportunity = @match.opportunity
    current_decision = @match.current_decision
    @show_client_info = @match.show_client_info_to?(access_context.current_contact)
    @sub_program = @match.sub_program
    @program = @match.program
    sub_program_has_files = @sub_program.file_tags.exists?
    can_see_client_details = @client&.has_full_housing_release? || can_view_all_clients?

    # Only show files if the user has access to the client details,
    # If the client has a full release on file or the user can see all clients
    # AND if the sub-program has file tags specified
    @show_files = @show_client_info && can_see_client_details && sub_program_has_files
    if @show_files && Warehouse::Base.enabled?
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
    if current_decision.try(:accessible_by?, current_contact) || @match.stalled?
      @decision = current_decision
    end
    set_update
  end
end
