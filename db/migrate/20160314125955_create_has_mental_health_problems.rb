class CreateHasMentalHealthProblems < ActiveRecord::Migration[4.2]
  def change
    create_table :has_mental_health_problems do |t|
      t.integer :numeric
      t.string :text

      t.timestamps null: false
    end
  end
end
