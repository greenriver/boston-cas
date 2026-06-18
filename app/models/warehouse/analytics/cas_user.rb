###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Warehouse::Analytics::CasUser < ::Warehouse::Base
  self.table_name = 'cas_analytics_cas_users'
  def self.sync!
    transaction do
      connection.execute("TRUNCATE TABLE #{quoted_table_name}")
      ::User.all.preload(:agency).find_in_batches(batch_size: 1_000) do |users|
        batch = []
        users.each do |user|
          batch << new(
            id: user.id,
            email: user.email,
            agency_id: user.agency_id,
            agency_name: user.agency&.name,
            created_at: user.created_at,
            updated_at: user.updated_at,
          )
        end
        import!(batch)
      end
    end
  end
end
