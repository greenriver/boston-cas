###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class AddVacancyPermissionsToRoles < ActiveRecord::Migration[7.0]
  def change
    add_column :roles, :can_review_vacancies, :boolean, default: false, null: false
  end
end
