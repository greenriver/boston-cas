class CreateActivityLogTable < ActiveRecord::Migration[6.0]
  def change
    create_table :activity_logs do |t|
      t.string :item_model
      t.integer :item_id
      t.string :title
      t.integer :user_id, null: false
      t.string :controller_name, null: false
      t.string :action_name, null: false
      t.string :method
      t.string :path
      t.string :ip_address, null: false
      t.string :session_hash
      t.text :referrer
      t.datetime :created_at
      t.datetime :updated_at
      t.index [:controller_name], name: :index_activity_logs_on_controller_name
      t.index [:created_at, :item_model, :user_id], name: :index_activity_logs_on_created_at_and_item_model_and_user_id
      t.index [:created_at], name: :activity_logs_created_at_idx, using: :brin
      t.index [:created_at], name: :created_at_idx, using: :brin
      t.index [:item_model, :user_id, :created_at], name: :index_activity_logs_on_item_model_and_user_id_and_created_at
      t.index [:item_model, :user_id], name: :index_activity_logs_on_item_model_and_user_id
      t.index [:item_model], name: :index_activity_logs_on_item_model
      t.index [:user_id, :item_model, :created_at], name: :index_activity_logs_on_user_id_and_item_model_and_created_at
      t.index [:user_id], name: :index_activity_logs_on_user_id
    end
  end
end
