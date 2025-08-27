###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Warehouse::Analytics::ReferralContact < ::Warehouse::Base
  self.table_name = 'cas_analytics_referral_contacts'
  def self.sync!
    transaction do
      connection.execute("TRUNCATE TABLE #{quoted_table_name}")
      # All matches for HMIS (warehouse) clients
      ::ClientOpportunityMatchContact.joins(:contact, match: { client: :project_client, opportunity: :voucher }).
        merge(ProjectClient.from_hmis).
        preload(:contact, match: :match_route).
        find_in_batches(batch_size: 1_000) do |match_contacts|
        batch = []
        match_contacts.each do |match_contact|
          batch << new(
            email: match_contact.contact.email,
            referral_id: match_contact.match.id,
            cas_user_id: match_contact.contact.user_id,
            contact_id: match_contact.contact_id,
            contact_type: match_contact.match.match_route.contact_label_for(match_contact.contact_type),
            created_at: match_contact.created_at,
            updated_at: match_contact.updated_at,
          )
        end
        import!(batch)
      end

      # Additionally, anyone who has the ability to user_can_reject_matches? or user_can_approve_matches?
      # (matches access for MatchDecisions::Base#admin_only?)
      match_admins = User.active.match_admins.joins(:contact).preload(:contact).to_a
      ClientOpportunityMatch.find_in_batches(batch_size: 1_000) do |matches|
        batch = []
        matches.each do |match|
          match_admins.each do |user|
            batch << new(
              email: user.contact.email,
              referral_id: match.id,
              cas_user_id: user.id,
              contact_id: user.contact.id,
              contact_type: 'Match Administrator',
              created_at: user.contact.created_at,
              updated_at: user.contact.updated_at,
            )
          end
        end
        import!(batch)
      end
    end
  end
end
