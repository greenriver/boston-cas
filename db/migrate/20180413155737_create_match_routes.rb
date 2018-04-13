class CreateMatchRoutes < ActiveRecord::Migration
  def change
    create_table :match_routes do |t|
      t.string :type, null: false
      t.boolean :active, null: false, default: true
      t.integer :weight, null: false, default: 10
      t.boolean :contacts_editable_by_hsa, null: false, default: false
      t.timestamps null: false
    end

    MatchRoutes::Base.ensure_all

    add_reference :programs, :match_route, default: MatchRoutes::Default.first.id

  end
end
