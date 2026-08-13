###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class AddVacancySubmissionConfig < ActiveRecord::Migration[7.2]
  def change
    add_column :configs, :vacancy_submission_mechanism, :string, default: 'Traditional'
  end
end
