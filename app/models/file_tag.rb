###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class FileTag < ApplicationRecord
  belongs_to :sub_program

  def self.available_tags
    return [] unless Warehouse::Base.enabled?
    Warehouse::Tag.available
  end
end
