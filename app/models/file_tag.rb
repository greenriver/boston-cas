###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class FileTag < ActiveRecord::Base
  belongs_to :sub_program

  def self.available_tags
    return [] unless Warehouse::Base.enabled?
    Warehouse::Tag.available
  end
end