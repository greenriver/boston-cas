###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class History::DeidentifiedClientsController < DeidentifiedClientsController
  before_action :require_can_manage_deidentified_clients!, only: [:active]

  def active

  end

  def load_client
    @non_hmis_client = client_source.find params[:id].to_i
  end

  private def user_ids
    @user_ids ||= @non_hmis_client.versions.where.not(user_id: nil).pluck(:user_id, :id, :created_at).map(&:first).uniq
  end

  private def users
    @users ||= User.where(id: user_ids).index_by(&:id)
  end

  def name_of_whodunnit(version)
    who = version.whodunnit&.to_i
    users[who]&.name if who.present?
  end
  helper_method :name_of_whodunnit

  def describe_changes_to(version)
    klass = version.item_type.constantize
    klass.describe_changes(version, get_changes_to(version))
  end
  helper_method :describe_changes_to



  private def get_changes_to(version)
    if version.object_changes.blank?
      compute_changes_to(version)
    else
      version.changeset
    end
  end

  private def compute_changes_to(version)
    changed = {}
    current = version.reify
    if current.present? && version.event != 'destroy'
      if version.previous.present? && version.previous.object.present?
        previous = version.previous.reify
        changed_attr = (current.attributes.to_a - previous.attributes.to_a).map(&:first)
        changed_attr.each do |name|
          changed[name] = [previous[name], current[name]]
        end
      else
        # A create - so, all attributes are new
        current.attributes.to_a.each do |name|
          changed[name] = [nil, current[name]]
        end
      end
      # TODO: cache computed change
      # copy_of_changed = changed.clone # Serialize can be in place, so we clone to avoid stepping on the changed map
      # serializer = PaperTrail::AttributeSerializers::ObjectChangesAttribute.new(current.class)
      # serializer.serialize(copy_of_changed)

      # version.object_changes = copy_of_changed
      # version.save`
    elsif current.present?
      # Describe a destroy as setting all attributes to nil
      current.attributes.map(&:first).each do |name|
        changed[name] = [current[name], nil]
      end
    end
    changed
  end
end