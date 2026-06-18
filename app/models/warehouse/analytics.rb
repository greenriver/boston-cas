###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

# The Analytics module supports export of CAS to our analytics store. These tables are consumed view views in the warehouse analytics schema

# Data Flow:
# CAS::Analytics --> CAS db connection --> analytics views (warehouse)  --> DBT (external)
module Warehouse::Analytics
  def self.table_prefix = 'cas_analytics_'
end
