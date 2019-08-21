class CreateMatchRoutes < ActiveRecord::Migration
  def change
    create_table :match_routes do |t|
      t.string :type, null: false
      t.boolean :active, null: false, default: true
      t.integer :weight, null: false, default: 10
      t.boolean :contacts_editable_by_hsa, null: false, default: false
      t.timestamps null: false
    end

    # You might have to temporarily comment out references to tags in this
    # model to get past this. Had to mask a `belongs_to :tag` as well as a
    # validation with a check for the tag_id column existing. In the future,
    # this might not be enough if references to tags expand beyond these.
    MatchRoutes::Base.ensure_all
    default_route = MatchRoutes::Default.first.id || 1 

    add_reference :programs, :match_route, default: default_route

  end
end
