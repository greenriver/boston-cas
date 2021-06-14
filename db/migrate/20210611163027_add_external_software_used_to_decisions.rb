class AddExternalSoftwareUsedToDecisions < ActiveRecord::Migration[6.0]
  def change
    add_column :match_decisions, :external_software_used, :boolean, default: false, null: false
    add_column :match_decisions, :address, :string
  end
end
