class AddHivAidsToNonHmis < ActiveRecord::Migration[6.0]
  def change
    add_column :non_hmis_assessments, :hiv_aids, :boolean, default: false
    add_column :non_hmis_clients, :hiv_aids, :boolean, default: false
  end
end
