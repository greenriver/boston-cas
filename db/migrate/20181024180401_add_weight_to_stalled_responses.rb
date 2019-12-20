class AddWeightToStalledResponses < ActiveRecord::Migration[4.2]
  def change
    add_column :stalled_responses, :weight, :integer, null: false, default: 0
  end
end
