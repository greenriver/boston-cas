class AddVeteranEtcToDeidentifiedClients < ActiveRecord::Migration[4.2]
  def change
    add_column :deidentified_clients, :veteran, :boolean, default: false, null: false
    add_column :deidentified_clients, :rrh_desired, :boolean, default: false, null: false
    add_column :deidentified_clients, :youth_rrh_desired, :boolean, default: false, null: false
    add_column :deidentified_clients, :rrh_assessment_contact_info, :text
    add_column :deidentified_clients, :income_maximization_assistance_requested, :boolean, default: false, null: false
    add_column :deidentified_clients, :pending_subsidized_housing_placement, :boolean, default: false, null: false
  end
end
