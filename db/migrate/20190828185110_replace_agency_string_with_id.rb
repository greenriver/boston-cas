class ReplaceAgencyStringWithId < ActiveRecord::Migration
  def change
    rename_column :non_hmis_clients, :agency, :deprecated_agency
    add_reference :non_hmis_clients, :agency
  end
end
