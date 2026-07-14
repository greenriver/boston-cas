###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class FixDefaultCasing < ActiveRecord::Migration[7.2]
  def change
    change_column_default :configs, :vacancy_submission_mechanism, from: 'Traditional', to: 'traditional'
  end
end
