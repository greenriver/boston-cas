###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Neighborhood < ApplicationRecord

  scope :text_search, -> (text) do
    return none unless text.present?
    where(arel_table[:name].lower.matches("%#{text.downcase}%"))
  end

  def self.for_select
    options = {
      'Any Neighborhood / All Neighborhoods' => nil,
    }
    options.merge(Neighborhood.order(:name).pluck(:name, :id).to_h)

  end
end
