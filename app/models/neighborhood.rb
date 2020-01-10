###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Neighborhood < ActiveRecord::Base

  scope :text_search, -> (text) do
    return none unless text.present?
    where(arel_table[:name].lower.matches("%#{text.downcase}%"))
  end

end
