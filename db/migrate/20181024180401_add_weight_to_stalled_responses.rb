class AddWeightToStalledResponses < ActiveRecord::Migration
  def change
    add_column :stalled_responses, :weight, :integer, null: false, default: 0
  end
end
