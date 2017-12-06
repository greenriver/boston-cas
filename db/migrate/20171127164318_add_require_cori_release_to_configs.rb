class AddRequireCoriReleaseToConfigs < ActiveRecord::Migration
  def change
    add_column :configs, :require_cori_release, :boolean, default: true
  end
end
