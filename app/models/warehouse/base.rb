module Warehouse
  class Base < ActiveRecord::Base
    self.abstract_class = true
    establish_connection "#{Rails.env}_warehouse".parameterize.underscore.to_sym

    def self.enabled?
      @enabled ||= Warehouse::Base.connection.active? && Warehouse::Base.connection.table_exists?('cohorts') rescue false
    end
  end
end