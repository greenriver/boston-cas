class AddAdditionalProjectClientColumns < ActiveRecord::Migration[4.2]
  def change
    [:project_clients, :clients].each do |table|
      add_column table, :ineligible_immigrant, :boolean, null: false, default: false
      add_column table, :family_member, :boolean, null: false, default: false
      add_column table, :child_in_household, :boolean, null: false, default: false
    end
  end
end
