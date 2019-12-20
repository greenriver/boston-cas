class AddTriggersToTags < ActiveRecord::Migration[4.2]
  def change
    add_column :tags, :rrh_assessment_trigger, :boolean, default: false, null: false
  end
end
