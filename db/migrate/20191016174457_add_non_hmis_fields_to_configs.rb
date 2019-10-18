class AddNonHmisFieldsToConfigs < ActiveRecord::Migration
  def change
    add_column :configs, :non_hmis_fields, :text
  end
end
