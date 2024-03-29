###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class FileTag < ApplicationRecord
  belongs_to :sub_program

  def self.available_tags
    return [] unless Warehouse::Base.enabled?
    Warehouse::Tag.available
  end
end
