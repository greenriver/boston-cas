class AddHatColumnsToNonHmis < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_clients, :pregnancy_status, :boolean, default: :false
    add_column :non_hmis_assessments, :pregnancy_status, :boolean, default: :false
  end
end
