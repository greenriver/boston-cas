class AddColumnsToClient < ActiveRecord::Migration
  def change
    [
      :us_citizen,
      :assylee,
      :lifetime_sex_offender,
      :meth_production_conviction,
    ].each do |column|
      add_column :clients, column, :boolean, default: false, null: false
      ProjectClient.where(column => nil).update_all(column => false)
      change_column :project_clients, column, :boolean, null: false, default: false
    end
  end
end
