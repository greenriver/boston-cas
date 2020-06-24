###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module ControlledVisibility
  extend ActiveSupport::Concern

  included do
    has_many :entity_view_permissions, as: :entity

    scope :visible_by, -> (user) {
      evp_t = EntityViewPermission.arel_table
      joins(:entity_view_permissions).where(
          evp_t[:agency_id].eq(user.agency_id)
      )
    }

    scope :editable_by, -> (user) {
      evp_t = EntityViewPermission.arel_table
      joins(:entity_view_permissions).where(
          evp_t[:agency_id].eq(user.agency_id),
          evp_t[:editable].eq(true)
      )
    }

    scope :visible_by_agency, -> (agency) {
      evp_t = EntityViewPermission.arel_table
      joins(:entity_view_permissions).where(
        evp_t[:agency_id].eq(agency.id)
      )
    }

    scope :editable_by_agency, -> (agency) {
      evp_t = EntityViewPermission.arel_table
      joins(:entity_view_permissions).where(
        evp_t[:agency_id].eq(agency.id),
        evp_t[:editable].eq(true)
      )
    }
  end

  def visible_by? user
    entity_view_permissions.where(agency_id: user.agency_id).present?
  end

  def editable_by? user
    entity_view_permissions.where(agency_id: user.agency_id, editable: true).present?
  end
end