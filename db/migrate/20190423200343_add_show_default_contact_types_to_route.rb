class AddShowDefaultContactTypesToRoute < ActiveRecord::Migration[4.2]
  def change
    add_column :match_routes, :show_default_contact_types, :boolean, default: true
  end
end
