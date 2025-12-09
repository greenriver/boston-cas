###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

module Warehouse
  class Base < ActiveRecord::Base
    self.abstract_class = true
    establish_connection "#{Rails.env}_warehouse".parameterize.underscore.to_sym

    def self.enabled?
      return @enabled if defined?(@enabled)

      @enabled = connection_pool.with_connection do |conn|
        conn.data_source_exists?('cohorts')
      end
    rescue StandardError => e
      Rails.logger.info("Warehouse unavailable: #{e.message}")
      @enabled = false
    end
  end
end
