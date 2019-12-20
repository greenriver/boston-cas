class AddNonHmisFieldsToConfigs < ActiveRecord::Migration[4.2]
  def change
    add_column :configs, :non_hmis_fields, :text
  end
end
