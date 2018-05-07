class AddDeidenifiedClientsTable < ActiveRecord::Migration
  def change
    create_table :deidentified_clients do |t|
      t.string :client_identifier
      t.integer :assessment_score
      t.string :agency 
      t.string :first_name, default: "Anonymous"
      t.string :last_name, default: "Anonymous"
      t.jsonb :active_cohort_ids 
      
      t.timestamps null: false
    end
  end
end
