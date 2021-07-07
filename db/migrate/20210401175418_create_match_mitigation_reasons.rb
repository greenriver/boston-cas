class CreateMatchMitigationReasons < ActiveRecord::Migration[6.0]
  def change
    create_table :match_mitigation_reasons do |t|
      t.references :client_opportunity_match
      t.references :mitigation_reason
      t.boolean :addressed, default: :false

      t.timestamps
    end
  end
end
