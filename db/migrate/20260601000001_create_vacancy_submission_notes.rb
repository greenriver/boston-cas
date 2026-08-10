###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class CreateVacancySubmissionNotes < ActiveRecord::Migration[7.0]
  def change
    create_table :vacancy_submission_notes do |t|
      t.references :vacancy_submission, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :note_type, null: false
      t.text :body, null: false
      t.timestamps
    end
  end
end
