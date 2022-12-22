###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
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
    can_see_client_details = @client&.has_full_housing_release?(@opportunity.match_route) || can_view_all_clients?
    file_tag_ids = @match.associated_file_tags
    required_tag_ids = file_tag_ids - @sub_program.file_tags.pluck(:tag_id)
    sub_program_has_files = file_tag_ids.size.positive?

    # Only show files if the user has access to the client details,
    # If the client has a full release on file or the user can see all clients
    # AND if the sub-program has file tags specified
    @show_files = @show_client_info && can_see_client_details && sub_program_has_files
    if @show_files && Warehouse::Base.enabled?
      t_t = Warehouse::Tagging.arel_table
      columns = {
        id: :id,
        updated_at: :updated_at,
        tag_id: t_t[:tag_id].as('tag_id').to_sql,
      }
      available_files = Warehouse::File.for_client(@client.remote_id).
        joins(:taggings).
        where(t_t[:tag_id].in(file_tag_ids)).
        order(updated_at: :desc).
        pluck(*columns.values).map do |row|
          OpenStruct.new(Hash[columns.keys.zip(row)])
        end
      @files = Warehouse::Tag.find(file_tag_ids).map do |tag|
        file = available_files.detect { |f| f.tag_id == tag.tag_id }
        required = tag.id.in?(required_tag_ids)
        if file
          [tag.name, [required, file]]
        else
          [tag.name, [required, nil]]
        end
      end.to_h
    end
    @decision = current_decision if current_decision.try(:accessible_by?, current_contact) || @match.stalled? || current_decision.try(:declineable_by?, current_contact)
    set_update
  end
end
