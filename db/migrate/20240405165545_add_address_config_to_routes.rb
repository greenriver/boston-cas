class AddAddressConfigToRoutes < ActiveRecord::Migration[6.1]
  def change
    add_column :match_routes, :show_referral_source, :boolean, default: false
    add_column :match_routes, :show_move_in_date, :boolean, default: false
    add_column :match_routes, :show_address_field, :boolean, default: false

    MatchRoutes::Four.update_all(show_address_field: true, show_referral_source: true, show_move_in_date: true)
  end
end
