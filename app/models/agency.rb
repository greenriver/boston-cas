###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class Agency < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :entity_view_permissions

  scope :text_search, -> (text) do
    return none unless text.present?

    where(arel_table[:name].lower.matches("%#{text.downcase}%"))
  end

  def program_names
    Program.editable_by_agency(self).order(:name).pluck(:name).join(', ')
  end

  def self.available_for_users
    order(:name)
  end
end
