###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include ArelHelper
  primary_abstract_class
  self.filter_attributes = Rails.application.config.filter_parameters
end
