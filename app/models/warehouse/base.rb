###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

module Warehouse
  class Base < ActiveRecord::Base
    self.abstract_class = true
    establish_connection "#{Rails.env}_warehouse".parameterize.underscore.to_sym

    def self.enabled?
      @enabled ||= Warehouse::Base.connection.active? && Warehouse::Base.connection.data_source_exists?('cohorts') rescue false
    end
  end
end