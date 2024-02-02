###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Tag < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  has_many :match_routes, class_name: MatchRoutes::Base.name

  scope :text_search, -> (text) do
    return none unless text.present?
    where(arel_table[:name].lower.matches("%#{text.downcase}%"))
  end

  def on_cohort?
    return false unless id.present?
    Warehouse::Cohort.active.where(tag_id: id).exists?
  end

end
