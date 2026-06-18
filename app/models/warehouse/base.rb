###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
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
