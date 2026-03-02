###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include ArelHelper
  primary_abstract_class
  self.filter_attributes = Rails.application.config.filter_parameters
end
