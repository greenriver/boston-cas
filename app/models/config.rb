###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Config < ApplicationRecord
  after_save :invalidate_cache
  before_create :set_defaults
  serialize :non_hmis_fields, Array

  def invalidate_cache
    self.class.invalidate_cache
  end

  def set_defaults
    self.dnd_interval ||= if Rails.env.production?
      7 # days
    else
      1
    end

    self.warehouse_url = 'https://hmis.boston.gov'
  end

  def self.invalidate_cache
    @settings = nil
    @settings_update_at = nil
  end

  def self.get(config)
    # Use cached config for 30 seconds
    return @settings.public_send(config) if @settings && @settings_update_at.present? && @settings_update_at > 30.seconds.ago

    @settings = first_or_create
    @settings_update_at = Time.current
    @settings.public_send(config)
  end

  def include_note_in_email_options
    @include_note_in_email_options ||= {
      'Never include match notes in email notifications' => nil,
      'Allow match notes in email notifications (default to no)' => false,
      'Allow match notes in email notifications (default to yes)' => true,
    }.freeze
  end
end
