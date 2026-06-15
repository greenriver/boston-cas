###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class CreateVacancySubmissions < ActiveRecord::Migration[7.0]
  def change
    create_table :vacancy_submissions do |t|
      t.references :user, null: true, foreign_key: true
      t.string :status, null: false, default: 'awaiting_approval'
      t.jsonb :draft_data, null: false, default: {}
      t.timestamps
    end

    add_index :vacancy_submissions, :status
    add_index :vacancy_submissions, :draft_data, using: :gin
  end
end
