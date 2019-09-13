class AddVispdatPrioritizationSchemeToConfigs < ActiveRecord::Migration
  def change
    add_column :configs, :vispdat_prioritization_scheme, :string, default: 'length_of_time'
  end
end
