class AddPathwaysSharePermissionColumn < ActiveRecord::Migration[6.1]
  def change
    add_column :non_hmis_assessments, :share_information_permission, :boolean
  end
end
