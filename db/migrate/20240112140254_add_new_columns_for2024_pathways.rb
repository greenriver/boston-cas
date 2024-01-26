class AddNewColumnsFor2024Pathways < ActiveRecord::Migration[6.1]
  def change
    add_column :non_hmis_assessments, :agency_name, :text
    add_column :non_hmis_assessments, :agency_day_contact_info, :text
    add_column :non_hmis_assessments, :agency_night_contact_info, :text
    add_column :non_hmis_assessments, :interested_in_rapid_rehousing, :boolean
    add_column :non_hmis_assessments, :pregnant_or_parent, :boolean
    add_column :non_hmis_assessments, :partner_warehouse_id, :text
    add_column :non_hmis_assessments, :partner_name, :text
  end
end
