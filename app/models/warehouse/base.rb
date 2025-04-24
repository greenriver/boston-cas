# frozen_string_literal: true

###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module Warehouse
  class Base < ActiveRecord::Base
    self.abstract_class = true
    connects_to(
      database: {
        writing: "#{Rails.env}_warehouse".parameterize.underscore.to_sym,
        reading: "#{Rails.env}_warehouse".parameterize.underscore.to_sym,
      },
    )

    def self.enabled?
      @enabled ||= begin
                     Warehouse::Base.connection.active? && Warehouse::Base.connection.data_source_exists?('cohorts')
                   rescue StandardError
                     false
                   end
    end
  end
end
