###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Warehouse::Analytics::WorkflowContact < ::Warehouse::Base
  self.table_name = 'cas_analytics_workflow_contacts'
  def self.sync!
    transaction do
      delete_all
      # All matches for HMIS (warehouse) clients
      ::ClientOpportunityMatchContact.joins(:contact, match: { client: :project_client, opportunity: :voucher }).
        merge(ProjectClient.from_hmis).
        preload(:contact, match: :match_route).
        find_in_batches(batch_size: 1_000) do |match_contacts|
        batch = []
        match_contacts.each do |match_contact|
          batch << new(
            id: match_contact.id,
            email: match_contact.contact.email,
            workflow_id: match_contact.match.id,
            contact_id: match_contact.contact_id,
            contact_type: match_contact.match.match_route.contact_label_for(match_contact.contact_type),
            created_at: match_contact.created_at,
            updated_at: match_contact.updated_at,
          )
        end
        import!(batch)
      end
    end
  end
end
