class AddRequireCoriReleaseToConfigs < ActiveRecord::Migration[4.2][4.2]
  def change
    add_column :configs, :require_cori_release, :boolean, default: true
  end
end
