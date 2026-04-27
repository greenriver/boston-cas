###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Warehouse::Analytics::ReferralUser < ::Warehouse::Base
  self.table_name = 'cas_analytics_referral_users'
  def self.sync!
    transaction do
      connection.execute("TRUNCATE TABLE #{quoted_table_name}")
      # All matches for HMIS (warehouse) clients
      ::ClientOpportunityMatchContact.joins(contact: :user, match: { client: :project_client, opportunity: :voucher }).
        preload(:match, :contact).
        merge(ProjectClient.from_hmis).
        find_in_batches(batch_size: 1_000) do |match_contacts|
        batch = []
        match_contacts.each do |match_contact|
          batch << new(
            id: match_contact.id,
            email: match_contact.contact.email,
            referral_id: match_contact.match.id,
            cas_user_id: match_contact.contact.user_id,
          )
        end
        import!(batch)
      end

      next_id = maximum(:id) + 1
      # Additionally, anyone who has the ability to user_can_reject_matches? or user_can_approve_matches?
      # (matches access for MatchDecisions::Base#admin_only?)
      match_admins = User.active.match_admins.joins(:contact).preload(:contact).to_a
      ClientOpportunityMatch.find_in_batches(batch_size: 1_000) do |matches|
        batch = []
        matches.each do |match|
          match_admins.each do |user|
            batch << new(
              id: next_id,
              email: user.contact.email,
              referral_id: match.id,
              cas_user_id: user.id,
            )
            next_id += 1
          end
        end

        import!(batch)
      end
    end
  end
end
