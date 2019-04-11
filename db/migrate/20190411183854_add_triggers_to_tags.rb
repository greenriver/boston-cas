class AddTriggersToTags < ActiveRecord::Migration
  def change
    add_column :tags, :rrh_assessment_trigger, :boolean, default: false, null: false
  end
end
